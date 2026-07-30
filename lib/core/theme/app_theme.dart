import 'package:customer_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
 // افترض أنك وضعت ملفاتك في نفس المجلد

class AppTheme {
  AppTheme._(); // منع إنشاء نسخة من الكلاس

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primary, // الخلفية الكحلية التي ذكرتها
    
    // تعريف الـ ColorScheme (مهم جداً في Flutter الحديث)
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.iconColor,
      surface: AppColors.cardBg,
    ),

    // تخصيص الـ InputDecorationTheme لتوحيد الـ TextFields في التطبيق
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
      ),
    ),
    
    // يمكنك إضافة المزيد من الإعدادات هنا (مثل ElevatedButtonTheme)
  );
}