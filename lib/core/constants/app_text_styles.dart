import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ملاحظة: AppColors.primary لم يعد قيمة ثابتة (const) لأنه أصبح يتغيّر
  // حسب الـ Theme (Navy↔Beige)، لذلك حوّلنا هذا الـ Style من "const" إلى
  // getter عادي حتى يقرأ اللون الصحيح في كل مرة.
  static TextStyle get screenTitle => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle fieldHint = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );

  static const TextStyle link = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
   
    decorationColor: AppColors.textLink,
  );

  static const TextStyle linkBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.iconColor,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.iconColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
    
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );
  // لا حاجة لذكر fontFamily هنا لأنه سيأخذ من الـ Theme تلقائياً
// نفس الملاحظة أعلاه: getter بدل const لأن AppColors.primary أصبح يتغيّر
// حسب الوضع الفاتح/الداكن.
static TextStyle get screenhomeTitle => TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: AppColors.primary,
);
// في ملف AppTextStyles
static const TextStyle productDescription = TextStyle(
  fontSize:20 , // حجم أكبر قليلاً من bodySmall ليكون مريحاً للقراءة
  color: AppColors.textSecondary,
  height: 1.5, // إضافة ارتفاع للسطر ليكون النص أوضح
);
  
}