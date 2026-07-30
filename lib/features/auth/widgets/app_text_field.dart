import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/core/constants/app_sizes.dart';
import 'package:customer_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';


class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.fieldHint,
            prefixIcon: Icon(icon, color: AppColors.iconColor, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
              borderSide: const BorderSide(color: AppColors.borderFocused, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
              borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}