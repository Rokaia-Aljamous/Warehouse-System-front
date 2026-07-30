import 'package:customer_app/controllers/register_controller.dart';
import 'package:customer_app/features/auth/views/verify_Identity_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _controller = RegisterController();

  bool _showPassword = false;
  bool _showConfirmPass = false;
  bool _isLoading = false;
  String? _errorMessage;
  File? _profileImage;

  DateTime? _selectedBirthday;

  String? _selectedGovernorate;
  String? _selectedCountry;

  final List<String> _governorates = ['Damascus', 'Aleppo', 'Homs', 'Latakia'];
  final List<String> _countries = ['Syria', 'Lebanon', 'Jordan', 'UAE'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _onRegister() async {
    if (_selectedBirthday == null) {
      setState(() => _errorMessage = 'Please select your birthday');
      return;
    }

    _controller.birthdayCtrl.text =
        '${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}';

    await _controller.register(
      context: context,
      onLoading: () => setState(() {
        _isLoading = true;
        _errorMessage = null;
      }),
      onSuccess: (email) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerifyIdentityScreen(email: email)),
        );
      },
      onError: (msg, fieldErrors) => setState(() {
        _isLoading = false;
        _errorMessage = msg;
      }),
    );
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
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
        _controller.displayBirthdayCtrl.text =
            '${picked.day}/${picked.month}/${picked.year}';
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
                const SizedBox(height: 150),
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
                  child: Form(
                    key: _controller.formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Register',
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        _buildImageUpload(),
                        const SizedBox(height: AppSizes.xl),
                        AppTextField(
                          label: 'YOUR FULL NAME',
                          hint: 'full name',
                          icon: Icons.person_outline,
                          controller: _controller.fullNameCtrl,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'EMAIL',
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          controller: _controller.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Invalid email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'PHONE NUMBER',
                          hint: 'phone number',
                          icon: Icons.phone_outlined,
                          controller: _controller.phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'PASSWORD',
                          hint: 'password',
                          icon: Icons.lock_outline,
                          controller: _controller.passwordCtrl,
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'CONFIRM PASSWORD',
                          hint: 'confirm password',
                          icon: Icons.lock_outline,
                          controller: _controller.confirmPasswordCtrl,
                          obscureText: !_showConfirmPass,
                          validator: (v) => (v != _controller.passwordCtrl.text)
                              ? 'Passwords do not match'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _showConfirmPass = !_showConfirmPass,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'YOUR BIRTHDAY',
                          hint: 'your birthday',
                          icon: Icons.cake_outlined,
                          controller: _controller.displayBirthdayCtrl,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textHint,
                              size: 18,
                            ),
                            onPressed: _pickBirthday,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'SELECT YOUR LOCATION',
                          hint: 'your location',
                          icon: Icons.location_on_outlined,
                          controller: _controller.locationCtrl,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'GOVERNORATE',
                                Icons.map_outlined,
                                _selectedGovernorate,
                                _governorates,
                                (v) => setState(() => _selectedGovernorate = v),
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: _buildDropdownField(
                                'COUNTRY',
                                Icons.language_outlined,
                                _selectedCountry,
                                _countries,
                                (v) => setState(() => _selectedCountry = v),
                              ),
                            ),
                          ],
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSizes.md),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: AppSizes.md),
                        AppButton(
                          label: 'Register',
                          onPressed: _onRegister,
                          isLoading: _isLoading,
                          borderColor: AppColors.borderFocused,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Login',
                                style: AppTextStyles.linkBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.iconColor, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.borderFocused,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.borderFocused,
                  width: 1.5,
                ),
              ),
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

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
            ),
            child: _profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_profileImage!, fit: BoxFit.cover),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
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
