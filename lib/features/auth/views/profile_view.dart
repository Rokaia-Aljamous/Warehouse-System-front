import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../home/views/home_view.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../../orders/views/my_orders_view.dart';
import '../../return/views/myReturnsView.dart';
import '../repositories/auth_repository.dart';
import '../widgets/app_button.dart';
import 'edit_profile_view.dart';

/// "Profile" screen — matches Figma design "بروفايل".
///
/// Reuses the Auth `AppButton` widget and the Auth-style card layout
/// (rounded top container over a navy scaffold). Form fields are
/// read-only display rows showing the user's saved data.
///
/// Data is loaded from the backend: GET /api/customers/profile.
///
/// Edit icon in the header → [EditProfileView].
/// Delete Account button → confirmation dialog.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  String? _errorMessage;

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _birthday = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
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
        _fullName = profile.fullName;
        _email = profile.email;
        _phone = profile.phoneNumber;
        _birthday = profile.birthday ?? '-';
        _profileImageUrl = profile.profileImage;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersView()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyReturnsView()),
              );
              break;
          }
        },
      ),
      body: Stack(
        children: [
          // Navy background behind the top area (avatar zone), independent
          // of the Scaffold background so the bottom nav bar keeps its
          // rounded contrast against AppColors.cardBg.
          Container(
            color: AppColors.primary,
            height: 120,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 120),
                // Cream card with rounded top corners (Auth style)
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
                      : _errorMessage != null
                      ? _buildErrorState()
                      : Column(
                          children: [
                            Text(
                              'profile.title'.tr(),
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSizes.lg),

                            // ── Avatar + name ─────────────────────
                            _buildAvatar(),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              _fullName,
                              style: AppTextStyles.screenTitle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xl),

                            // ── Read-only field rows ──────────────
                            _ProfileField(
                              label: 'profile.full_name_label'.tr(),
                              value: _fullName,
                              icon: Icons.person_outline,
                            ),
                            _ProfileField(
                              label: 'auth.email_label'.tr(),
                              value: _email,
                              icon: Icons.email_outlined,
                            ),
                            _ProfileField(
                              label: 'auth.phone_number'.tr(),
                              value: _phone,
                              icon: Icons.phone_outlined,
                            ),
                            _ProfileField(
                              label: 'profile.birthday_label'.tr(),
                              value: _birthday,
                              icon: Icons.cake_outlined,
                            ),

                            const SizedBox(height: AppSizes.xl),
                            // ── Delete Account button ─────────────
                            AppButton(
                              label: 'profile.delete_account'.tr(),
                              onPressed: () =>
                                  _showDeleteConfirmDialog(context),
                              color: Colors.transparent,
                              textColor: const Color(0xFFDC2626),
                              borderColor: const Color(0xFFDC2626),
                              fullWidth: true,
                            ),
                            const SizedBox(height: AppSizes.xl),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Top header: back + title + edit (Auth style) ─────────
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => _safePop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileView()),
                );
                if (updated == true) {
                  // Reload saved data when returning from Edit Profile.
                  _loadProfile();
                }
              },
              icon: const Icon(Icons.edit, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar circle — shows the network image when available, otherwise a
  /// placeholder icon.
  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: _profileImageUrl != null
            ? DecorationImage(
                image: NetworkImage(_profileImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _profileImageUrl == null
          ? const Icon(Icons.person, size: 40, color: AppColors.iconColor)
          : null,
    );
  }

  /// Shown when loading the profile from the backend fails
  /// (no token, no internet, server error, ...).
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 40),
          const SizedBox(height: AppSizes.sm),
          Text(
            _errorMessage ?? 'common.error_generic'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSizes.md),
          AppButton(
            label: 'common.try_again'.tr(),
            onPressed: _loadProfile,
            color: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.primary,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'profile.delete_account'.tr(),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'profile.delete_confirm_body'.tr(),
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('profile.delete_demo'.tr()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'profile.delete'.tr(),
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  /// Pops safely — only pops if there's a previous route, otherwise no-op.
  void _safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

/// Read-only profile field — same visual language as the Auth `AppTextField`
/// but displays a value instead of an editable input.
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
              border: Border.all(color: AppColors.borderFocused, width: 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.iconColor, size: 20),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
