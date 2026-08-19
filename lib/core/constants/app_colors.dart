import 'package:flutter/material.dart';
import 'package:customer_app/core/theme/theme_controller.dart';

class AppColors {
  AppColors._();

  // ── اللونان الأساسيان القابلان للعكس بين الوضعين ──────────────────────────
  // Light Mode: Navy هو الأساسي (خلفية الـ Scaffold/الـ Navigation) و Beige هو
  // خلفية الـ Card. في Dark Mode ينعكس الاثنان مع بعض فقط، ولا يتأثر أي لون آخر.
  static const Color _navy  = Color(0xff1D2D44); // الكحلي الأصلي
  static const Color _beige = Color(0xFFFFF8F4); // البيج الأصلي

  /// اللون الأساسي (Navy في Light ↔ Beige في Dark).
  /// يُستخدم لخلفية الـ Scaffold والـ Navigation Bar وعناصر أخرى مرتبطة به مباشرة.
  static Color get primary =>
      ThemeController.instance.isDark ? _beige : _navy;

  /// خلفية الـ Card (Beige في Light ↔ Navy في Dark) — تتبع نفس زوج
  /// الانعكاس لأن قيمتها الحالية هي نفسها اللون الأساسي (Beige)، وبالتالي
  /// تتغيّر معه بشكل مقصود ومركزي، وليس عبر فلتر عشوائي يشمل كل الشاشة.
  static Color get cardBg =>
      ThemeController.instance.isDark ? _navy : _beige;

  // ── ألوان ثابتة لا تتغير أبداً بين الـ Light/Dark (حسب الطلب) ─────────────
  static const Color iconColor      = Color(0xFFF3A523); // البرتقالي — ثابت دائماً
  static const Color textLink       = Color(0xFF5A7BF0); // روابط — ثابت
  static const Color border         = Color(0xFFB8B8B8); // حدود TextField — ثابت
  static const Color borderFocused  = Color(0xFF1E3A5F); // ثابت (خاص بالـ Input Fields)

  // ── نصوص: تتغيّر حسب الخلفية لضمان التباين والوضوح ────────────────────────
  // القيم الأصلية (المستخدمة غالباً فوق عناصر فاتحة/الـ Cards والـ Inputs
  // الثابتة) تبقى كما هي بدون تغيير — لأن الـ Cards والـ Input Fields أنفسها
  // لا تنعكس ألوانها (باستثناء cardBg كما هو موضّح أعلاه).
  static const Color textPrimary    = Color(0xFF1E3A5F); // نص داكن (فوق الأسطح الفاتحة الثابتة)
  static const Color textSecondary  = Color(0xFF8B6B5E); // label
  static const Color textHint       = Color(0xFFB0A89E); // hint

  /// نص واضح فوق اللون الأساسي (primary) تحديداً — يُستخدم في العناصر التي
  /// خلفيتها AppColors.primary (Scaffold/Navigation)، حتى يبقى مقروءًا سواء
  /// كانت الخلفية Navy (Light) أو Beige (Dark).
  static Color get textOnPrimary =>
      ThemeController.instance.isDark ? _navy : Colors.white;

  /// نص واضح فوق الـ Card (cardBg) تحديداً — يبقى مقروءًا سواء كانت خلفية
  /// الكارد Beige (Light) أو Navy (Dark).
  static Color get textOnCard =>
      ThemeController.instance.isDark ? Colors.white : _navy;
  static const Color purple     = Color(0xFF7B61FF); // لون الأيقونات الجديد بالريجستر
static const Color uploadBox  = Color(0xFFEDE8F5);  // حدود TextField focused

static const Color statusShippingBg  = Color(0xFFE8F4FD);
  static const Color statusShippingTxt  = Color(0xFF1565C0);
  
  static const Color statusPendingBg   = Color(0xFFFFDAD6);
  static const Color statusPendingTxt   = Color(0xFf93000A);
  
  static const Color statusApprovedBg  = Color(0xFFE8F5E9);
  static const Color statusApprovedTxt  = Color(0xFF2E7D32);
  
  static const Color statusCancelledBg = Color(0xFFFFEBEE);
  static const Color statusCancelledTxt = Color(0xFFC62828);
  static const Color warehouseBg = Color(0xFFFFF1E6);
}