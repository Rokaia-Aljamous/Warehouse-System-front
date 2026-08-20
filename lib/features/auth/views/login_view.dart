import 'package:customer_app/controllers/login_controller.dart';
import 'package:customer_app/core/storage/token_storage.dart';
import 'package:customer_app/features/auth/views/forget_password_view.dart';
import 'package:customer_app/features/auth/views/register_view.dart';
import 'package:customer_app/features/auth/widgets/app_button.dart';
import 'package:customer_app/features/auth/widgets/app_text_field.dart';
import 'package:customer_app/features/home/views/home_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with WidgetsBindingObserver {
  final _controller = LoginController();
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isWaitingForGoogle = false; // ← نراقب إذا المستخدم راح على Chrome

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← نراقب lifecycle التطبيق
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// لما المستخدم يرجع من Chrome للتطبيق، هاد بيتفعل.
  /// إذا الـ deep link ما وصل (يعني المستخدم ألغى)، نطلع الـ loading.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForGoogle) {
      // نستنى شوي لين ما الـ deep link يتعالج (لو فيه)
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return; // التطبيق انتقل لشاشة تانية = نجح
        TokenStorage.hasToken().then((hasToken) {
          if (mounted && !hasToken) {
            // ما في token = المستخدم ألغى تسجيل الدخول
            setState(() {
              _isLoading = false;
              _isWaitingForGoogle = false;
            });
          }
          // لو فيه token، main.dart بكون انتقل للـ HomeView فعلاً
        });
      });
    }
  }

  Future<void> _onLogin() async {
    await _controller.login(
      context: context,
      onLoading: () => setState(() {
        _isLoading = true;
        _errorMessage = null;
      }),
      onSuccess: () {
        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
        );
      },
      onError: (msg) => setState(() {
        _isLoading = false;
        _errorMessage = msg;
      }),
    );
  }

  Future<void> _onGoogleLogin() async {
    setState(() {
      _isWaitingForGoogle = true;
      _errorMessage = null;
    });

    await _controller.loginWithGoogleExternal(
      context: context,
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: () {}, // ما بيستعمل (main.dart بيتعامل مع التنقل)
      onError: (msg) => setState(() {
        _isLoading = false;
        _isWaitingForGoogle = false;
        _errorMessage = msg;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SizedBox(height: AppSizes.topPageSpacing),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.cardBorderRadius),
                  topRight: Radius.circular(AppSizes.cardBorderRadius),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.xl,
                ),
                child: Form(
                  key: _controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'auth.login_title'.tr(),
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      AppTextField(
                        label: 'auth.email'.tr(),
                        hint: 'auth.email_hint'.tr(),
                        icon: Icons.email_outlined,
                        controller: _controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'auth.email_required'.tr();
                          if (!v.contains('@'))
                            return 'auth.email_invalid'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      AppTextField(
                        label: 'auth.password'.tr(),
                        hint: 'auth.password_hint'.tr(),
                        icon: Icons.lock_outline,
                        controller: _controller.passwordCtrl,
                        obscureText: !_showPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'auth.password_required'.tr();
                          if (v.length < 6) return 'auth.password_min'.tr();
                          return null;
                        },
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
                      const SizedBox(height: AppSizes.sm),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordView(),
                            ),
                          ),
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: AppTextStyles.link,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      AppButton(
                        label: 'auth.login_button'.tr(),
                        onPressed: _onLogin,
                        isLoading: _isLoading,
                        borderColor: AppColors.borderFocused,
                        color: AppColors.cardFixedBg,
                      ),
                      const SizedBox(height: AppSizes.md),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                            ),
                            child: Text(
                              'auth.or'.tr(),
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      AppButton(
                        label: 'auth.continue_google'.tr(),
                        onPressed: _onGoogleLogin,
                        fullWidth: true,
                        borderColor: AppColors.borderFocused,
                        color: AppColors.cardFixedBg,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.no_account'.tr(),
                            style: AppTextStyles.bodySmall,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterView(),
                              ),
                            ),
                            child: Text(
                              'auth.create_account'.tr(),
                              style: AppTextStyles.linkBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
