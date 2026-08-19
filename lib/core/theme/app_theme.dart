import 'package:customer_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // منع إنشاء نسخة من الكلاس

  /// ثيم واحد مُولَّد لكل من Light وDark عبر buildTheme(isDark:), لأن كل
  /// الألوان الأساسية في AppColors أصبحت "واعية بالثيم" بنفسها (primary
  /// وcardBg ينعكسان تلقائياً حسب ThemeController.instance.isDark)، ولا داعي
  /// لأي فلتر عام (ColorFiltered / ColorFilter.matrix) يشوّه بقية الألوان
  /// الثابتة (البرتقالي، الأخضر، الـ Cards المستقلة، الـ Input Fields).
  ///
  /// ملاحظة مهمة: تم استبدال أسلوب "فلتر لوني فوق الشاشة كلها" بالكامل، لأنه
  /// كان يعكس كل الألوان بدون تمييز — وهذا بالضبط ما طُلب تجنّبه. الآن
  /// الانعكاس يقتصر فقط على اللونين الأساسيين (Beige↔Navy) عبر AppColors.
  static ThemeData buildTheme({required bool isDark}) => ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        fontFamily: 'Inter',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primary, // الخلفية الأساسية (Navy↔Beige)

        // تعريف الـ ColorScheme (مهم جداً في Flutter الحديث)
        colorScheme:
            (isDark ? const ColorScheme.dark() : const ColorScheme.light())
                .copyWith(
          primary: AppColors.primary,
          secondary: AppColors.iconColor, // البرتقالي — ثابت في كل الأوضاع
          surface: AppColors.cardBg,
        ),

        // تخصيص الـ InputDecorationTheme لتوحيد الـ TextFields في التطبيق —
        // هذه القيم ثابتة عمداً في كل من Light وDark حسب الطلب (لا تتبع
        // انعكاس Beige/Navy).
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.borderFocused, width: 2),
          ),
        ),

        // يمكنك إضافة المزيد من الإعدادات هنا (مثل ElevatedButtonTheme)
      );

  static ThemeData get lightTheme => buildTheme(isDark: false);
  static ThemeData get darkTheme => buildTheme(isDark: true);
}
