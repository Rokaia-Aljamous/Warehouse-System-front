import 'dart:async';
import 'package:customer_app/controllers/verify_identity_controller.dart';
import 'package:customer_app/features/auth/views/login_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_button.dart';

class VerifyIdentityScreen extends StatefulWidget {
  final String email;
  const VerifyIdentityScreen({super.key, required this.email});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  final _controller = VerifyIdentityController();
  bool _isChecking = false;
  String? _errorMessage;
  int _secondsRemaining = 30;
  Timer? _resendTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  // ── مؤقت إعادة الإرسال ──────────────────────────────────
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

  // ── polling: كل ثانيتين نسأل الباك هل اتأكد الإيميل ────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      final verified = await _controller.checkVerification(email: widget.email);
      if (verified && mounted) {
        _pollTimer?.cancel();
        _goToLogin();
      }
    });
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _resendTimer?.cancel();
    _pollTimer?.cancel();
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
                  decoration: BoxDecoration(
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
                        'auth.verify_email_title'.tr(),
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'auth.verification_link_sent'.tr(args: [widget.email]),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'auth.open_email_verify'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // ── مؤشر الانتظار ──────────────────
                      if (_isChecking)
                        CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      else
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          value: null,
                        ),

                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'auth.waiting_verification'.tr(),
                        style: AppTextStyles.bodySmall,
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

                      // ── زر إعادة الإرسال ───────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.didnt_receive_email'.tr(),
                            style: AppTextStyles.bodySmall,
                          ),
                          GestureDetector(
                            onTap: _secondsRemaining == 0
                                ? () => _controller.resendCode(
                                    email: widget.email,
                                    onSuccess: _startResendTimer,
                                    onError: (msg) =>
                                        setState(() => _errorMessage = msg),
                                  )
                                : null,
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

                      // ── زر التحقق اليدوي ───────────────
                      AppButton(
                        label: 'auth.already_verified'.tr(),
                        isLoading: _isChecking,
                        onPressed: () async {
                          setState(() => _isChecking = true);
                          final verified = await _controller.checkVerification(
                            email: widget.email,
                          );
                          setState(() => _isChecking = false);
                          if (verified) {
                            _goToLogin();
                          } else {
                            setState(
                              () =>
                                  _errorMessage = 'auth.not_verified_yet'.tr(),
                            );
                          }
                        },
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
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.mail_outline, size: 40, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_circle, size: 18, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
