import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتحكم بوضع المظهر (فاتح/داكن) ويخزنه محلياً.
/// AppColors.primary وAppColors.cardBg يقرآن isDark من هنا مباشرة
/// (Navy↔Beige)، وMaterialApp في main.dart يبني الثيم المناسب
/// (AppTheme.lightTheme / AppTheme.darkTheme) عند كل تبديل.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'theme_mode_dark';

  bool _isDark = false;
  bool get isDark => _isDark;

  /// يقرأ الوضع المحفوظ من الذاكرة المحلية.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  /// يبدّل بين الوضع الفاتح والداكن ويحفظ الاختيار.
  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, _isDark);
  }
}