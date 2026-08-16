import 'dart:async';

import 'package:customer_app/features/auth/views/create_password_view.dart';
import 'package:customer_app/features/auth/views/login_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../widgets/app_button.dart';

class ForgotPasswordWaitView extends StatefulWidget {
  final String email;
  const ForgotPasswordWaitView({super.key, required this.email});

  @override
  State<ForgotPasswordWaitView> createState() => _ForgotPasswordWaitViewState();
}

class _ForgotPasswordWaitViewState extends State<ForgotPasswordWaitView> {
  bool _isChecking = false;
  String? _errorMessage;
  int _secondsRemaining = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _secondsRemaining = 30);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _resendTimer?.cancel();
          }
        });
      }
    });
  }

  // نجيب الـ token من الباك مباشرة
  Future<String?> _getToken() async {
    try {
      final response = await DioClient.instance.get(
        '/api/customers/get-reset-token',
        queryParameters: {'email': widget.email},
      );
      return response.data['token'];
    } catch (e) {
      return null;
    }
  }

  void _goToCreatePassword(String token) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            CreateNewPasswordView(email: widget.email, token: token),
      ),
      (_) => false,
    );
  }

  Future<void> _resendEmail() async {
    try {
      await DioClient.instance.post(
        '/api/customers/forgot-password',
        data: {'email': widget.email},
      );
      _startResendTimer();
    } catch (e) {
      setState(() => _errorMessage = 'auth.resend_failed'.tr());
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
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
                  child: Column(
                    children: [
                      _buildIcon(),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'auth.check_email_title'.tr(),
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'auth.reset_link_sent'.tr(args: [widget.email]),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'auth.open_email_reset'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 60,
                        color: AppColors.primary,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: AppSizes.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.didnt_receive_email'.tr(),
                            style: AppTextStyles.bodySmall,
                          ),
                          GestureDetector(
                            onTap: _secondsRemaining == 0 ? _resendEmail : null,
                            child: Text(
                              _secondsRemaining > 0
                                  ? 'auth.resend_in'.tr(
                                      args: ['$_secondsRemaining'],
                                    )
                                  : 'auth.resend'.tr(),
                              style: AppTextStyles.linkBold.copyWith(
                                color: _secondsRemaining > 0
                                    ? Colors.grey
                                    : AppColors.iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.xl),

                      AppButton(
                        label: 'auth.already_clicked_link'.tr(),
                        isLoading: _isChecking,
                        onPressed: () async {
                          setState(() => _isChecking = true);
                          final token = await _getToken();
                          setState(() => _isChecking = false);
                          if (token != null) {
                            _goToCreatePassword(token);
                          } else {
                            setState(
                              () =>
                                  _errorMessage = 'auth.click_link_first'.tr(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: AppSizes.lg),
                      GestureDetector(
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginView()),
                          (_) => false,
                        ),
                        child: Text(
                          'auth.back_to_login'.tr(),
                          style: AppTextStyles.linkBold,
                        ),
                      ),
                    ],
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

  Widget _buildIcon() {
    return const SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.mail_outline,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
