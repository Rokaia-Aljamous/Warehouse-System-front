import 'package:customer_app/controllers/forgot_password_controller.dart';
import 'package:customer_app/features/auth/views/forgot_password_wait_view.dart';
import 'package:customer_app/features/auth/views/login_view.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _controller = ForgotPasswordController();
  bool _isLoading = false;
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
                        const Text(
                          'Forgot Password?',
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Enter your Email Address below and we\'ll send you a 4-digit code to reset your password.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 70),
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
                        const SizedBox(height: AppSizes.md),

                        // ── رسالة الخطأ ──────────────────────────
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: AppSizes.md),
                        AppButton(
                          label: 'Send Code',
                          isLoading: _isLoading,
                          borderColor: AppColors.borderFocused,
                          onPressed: () => _controller.sendCode(
                            onLoading: () => setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            }),
                            onSuccess: (email) {
                              setState(() => _isLoading = false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordWaitView(email: email),
                                ),
                              );
                            },
                            onError: (msg) => setState(() {
                              _isLoading = false;
                              _errorMessage = msg;
                            }),
                          ),
                        ),
                        const SizedBox(height: 210),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()),
                            (route) => false,
                          ),
                          child: const Text(
                            'Back to Login',
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}