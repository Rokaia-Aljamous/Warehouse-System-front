import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../repositories/auth_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// "Edit Profile" screen — matches Figma design "تعديل بروفايل".
///
/// Loads current data from the backend (GET /api/customers/profile),
/// lets the user edit it, then saves via PATCH /api/customers/profile.
///
/// NOTE: Password and Confirm Password fields are intentionally absent —
/// password change is handled via [ChangePasswordView] from the Drawer.
/// NOTE: Email is not editable — the backend rejects changes to it.
///
/// On "Save Changes":
///   - Sends full_name / birthday / phone_number / profile_image to the API.
///   - Pops back to Profile with `true` result so Profile reloads.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthRepository _authRepository = AuthRepository();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _birthdayCtrl;

  DateTime? _selectedBirthday;
  File? _pickedImage;
  String? _currentImageUrl;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _birthdayCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await TokenStorage.getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'profile.please_login_first'.tr();
      });
      return;
    }

    try {
      final profile = await _authRepository.getProfile(token: token);
      if (!mounted) return;
      setState(() {
        _fullNameCtrl.text = profile.fullName;
        _emailCtrl.text = profile.email;
        _phoneCtrl.text = profile.phoneNumber;
        if (profile.birthday != null) {
          _birthdayCtrl.text = profile.birthday!;
          _selectedBirthday = DateTime.tryParse(profile.birthday!);
        }
        _currentImageUrl = profile.profileImage;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = DioClient.getErrorMessage(e);
      });
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _birthdayCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
        // Laravel expects YYYY-MM-DD.
        _birthdayCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveChanges() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      setState(() => _errorMessage = 'profile.please_login_first'.tr());
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.updateProfile(
        token: token,
        fullName: _fullNameCtrl.text.trim(),
        birthday: _birthdayCtrl.text.trim().isEmpty
            ? null
            : _birthdayCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        profileImagePath: _pickedImage?.path,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // signal "data updated" to Profile
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = DioClient.getErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 120),
                // Cream rounded card — same style as RegisterView.
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.cardBorderRadius),
                      topRight: Radius.circular(AppSizes.cardBorderRadius),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                    vertical: AppSizes.xl,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          children: [
                            Text(
                              'profile.edit_title'.tr(),
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSizes.lg),
                            // ── Image upload (Register-style) ─────────
                            _buildImageUpload(),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              _fullNameCtrl.text.isEmpty
                                  ? ' '
                                  : _fullNameCtrl.text,
                              style: AppTextStyles.screenTitle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xl),

                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                            ],

                            // ── Editable fields ────────────────────────
                            AppTextField(
                              label: 'profile.full_name_label'.tr(),
                              hint: 'auth.full_name_hint'.tr(),
                              icon: Icons.person_outline,
                              controller: _fullNameCtrl,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'auth.email_label'.tr(),
                              hint: 'auth.email_hint'.tr(),
                              icon: Icons.email_outlined,
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              // Backend rejects changes to email, so keep
                              // it read-only here.
                              validator: null,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'auth.phone_number'.tr(),
                              hint: 'auth.phone_hint'.tr(),
                              icon: Icons.phone_outlined,
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'auth.birthday'.tr(),
                              hint: 'auth.birthday_hint'.tr(),
                              icon: Icons.cake_outlined,
                              controller: _birthdayCtrl,
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.textHint,
                                  size: 18,
                                ),
                                onPressed: _pickBirthday,
                              ),
                            ),

                            const SizedBox(height: AppSizes.lg),
                            // ── Save Changes button ────────────────────
                            AppButton(
                              label: _isSaving
                                  ? 'profile.saving'.tr()
                                  : 'profile.save_changes'.tr(),
                              onPressed: _isSaving ? () {} : _saveChanges,
                              color: AppColors.primary,
                              textColor: Colors.white,
                              borderColor: AppColors.primary,
                              fullWidth: true,
                            ),
                            const SizedBox(height: AppSizes.xl),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Top: back arrow (left) + close X (right) ──────────────
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  /// Image upload widget — shows the picked local image, otherwise the
  /// current network image from the backend, otherwise a placeholder.
  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 1.5),
              image: _pickedImage != null
                  ? DecorationImage(
                      image: FileImage(_pickedImage!),
                      fit: BoxFit.cover,
                    )
                  : (_currentImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_currentImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: (_pickedImage == null && _currentImageUrl == null)
                ? const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 36,
                  )
                : null,
          ),
          const Positioned(
            bottom: -6,
            right: -6,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: AppColors.cardBg, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
