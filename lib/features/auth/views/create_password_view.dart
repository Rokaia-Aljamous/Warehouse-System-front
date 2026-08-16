import 'package:customer_app/controllers/create_password_controller.dart';
import 'package:customer_app/features/auth/views/login_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class CreateNewPasswordView extends StatefulWidget {
  final String email;
  // الـ token بيوصل بالإيميل كـ link — حالياً بنمررو فاضي
  // لما يضيف الباك اند endpoint للـ OTP الرقمي رح نحدثه
  final String token;

  const CreateNewPasswordView({
    super.key,
    required this.email,
    this.token = '',
  });

  @override
  State<CreateNewPasswordView> createState() => _CreateNewPasswordViewState();
}

class _CreateNewPasswordViewState extends State<CreateNewPasswordView> {
  final _controller = CreatePasswordController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 150,
                  ),
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
                        Text(
                          'auth.create_new_password_title'.tr(),
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'auth.new_password_desc'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppSizes.xl),

                        AppTextField(
                          label: 'auth.new_password'.tr(),
                          hint: 'auth.new_password_hint'.tr(),
                          icon: Icons.lock_outline,
                          controller: _controller.newPassCtrl,
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'auth.password_too_short'.tr()
                              : null,
                        ),
                        const SizedBox(height: AppSizes.lg),

                        AppTextField(
                          label: 'auth.confirm_password'.tr(),
                          hint: 'auth.confirm_password_hint2'.tr(),
                          icon: Icons.lock_outline,
                          controller: _controller.confirmPassCtrl,
                          obscureText: !_showConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                          validator: (v) => (v != _controller.newPassCtrl.text)
                              ? 'auth.passwords_not_match'.tr()
                              : null,
                        ),

                        const SizedBox(height: AppSizes.md),

                        // ── رسالة خطأ ────────────────────────────
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: AppSizes.lg),
                        AppButton(
                          label: 'auth.reset_password_button'.tr(),
                          isLoading: _isLoading,
                          onPressed: () => _controller.resetPassword(
                            email: widget.email,
                            token: widget.token,
                            onLoading: () => setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            }),
                            onSuccess: () {
                              setState(() => _isLoading = false);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                                (route) => false,
                              );
                            },
                            onError: (msg) => setState(() {
                              _isLoading = false;
                              _errorMessage = msg;
                            }),
                          ),
                        ),

                        const SizedBox(height: 159),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginView(),
                            ),
                            (route) => false,
                          ),
                          child: Text(
                            'auth.back_to_login'.tr(),
                            style: AppTextStyles.linkBold,
                          ),
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
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
