class ApiConstants {
  ApiConstants._();
  static const String baseUrl =
      'https://immobile-abiding-facial.ngrok-free.dev';
  // static const String baseUrl = 'http://warehouse-system.test';

  /// الباك اند بيبني روابط الصور (main_image) اعتماداً على APP_URL بالـ
  /// .env تبعه (غالباً http://127.0.0.1:8000 أو http://localhost:8000).
  /// هاد العنوان من منظور محاكي أندرويد بيشاور على المحاكي نفسه، مش على
  /// جهاز الديفلوبر — فتحميل الصورة يفشل ويطلع الشكل الافتراضي بدلها،
  /// رغم إنه الـ API نفسه شغال لأنه baseUrl فوق معدّل يدوياً لـ 10.0.2.2.
  ///
  /// هاي الدالة بتاخد رابط الصورة القادم من الباك اند وتستبدل الـ
  /// scheme/host/port تبعه بنفس القيم المستخدمة فعلياً بـ baseUrl (يلي
  /// شغال أصلاً)، وتخلي رابط الصورة يشتغل بنفس الشرط بالضبط.
  static String? resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    try {
      final incoming = Uri.parse(rawUrl);
      final target = Uri.parse(baseUrl);
      return incoming
          .replace(scheme: target.scheme, host: target.host, port: target.port)
          .toString();
    } catch (_) {
      return rawUrl;
    }
  }

  // ── Auth endpoints ────────────────────────────────────────
  static const String register = '$baseUrl/api/customers/register';
  static const String login = '$baseUrl/api/customers/login';
  static const String forgotPassword = '$baseUrl/api/customers/forgot-password';
  static const String resetPassword = '$baseUrl/api/customers/reset-password';
  static const String verificationNotify =
      '$baseUrl/api/customers/email/verification-notification';
  static const String logout = '$baseUrl/api/customers/logout';

  // ── Warehouses endpoints ──────────────────────────────────
  static const String warehouses = '$baseUrl/api/customers/warehouses';

  // ── Profile endpoints ─────────────────────────────────────
  static const String profile = '$baseUrl/api/customers/profile';
}
