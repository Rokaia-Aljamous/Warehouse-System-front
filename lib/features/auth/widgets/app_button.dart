import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/core/constants/app_sizes.dart';
import 'package:customer_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

enum AppButtonType { primary, google }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool fullWidth;
  final Color? borderColor;
  final Color? color;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderColor,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : AppSizes.buttonMinWidth,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _style(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: AppColors.borderFocused,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (type == AppButtonType.google) ...[
                    Image.asset('assets/icons/google.png', height: 20),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Text(
                    label,
                    // استخدمنا textColor إذا تم تمريره، وإلا نستخدم النمط الافتراضي
                    style: textColor != null
                        ? AppTextStyles.buttonLabel.copyWith(color: textColor)
                        : AppTextStyles.buttonLabel,
                  ),
                ],
              ),
      ),
    );
  }

  // في ملف app_button.dart
  ButtonStyle _style() {
    // نقوم بتعريف اللون هنا ليكون بني عند التحميل
    final Color activeColor = isLoading
        ? AppColors.textSecondary
        : (borderColor ?? AppColors.primary);

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          // إذا تم تمرير لون (color)، نستخدمه، وإلا نستخدم اللون الافتراضي (AppColors.cardBg)
          backgroundColor: color ?? AppColors.cardBg,
          // foregroundColor يحدد لون الأيقونة والنص داخل الزر
          foregroundColor: textColor ?? activeColor,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
            // نستخدم لون الحدود الممرر، وإلا نستخدم activeColor
            side: BorderSide(color: borderColor ?? activeColor, width: 1.5),
          ),
        );
      case AppButtonType.google:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        );
    }
  }
}
