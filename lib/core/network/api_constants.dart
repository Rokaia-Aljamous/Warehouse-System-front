class ApiConstants {
  ApiConstants._();
  /// Override per environment with:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

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
