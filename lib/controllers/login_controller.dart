import 'package:customer_app/features/auth/repositories/auth_repository.dart';
import 'package:customer_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';

class LoginController {
  final AuthRepository _repository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  Future<void> login({
    required BuildContext context,
    required VoidCallback onLoading,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    onLoading();

    try {
      final user = await _repository.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      if (user.token != null) {
        await TokenStorage.saveToken(user.token!);
      }

      onSuccess();
    } on DioException catch (e) {
      onError(DioClient.getErrorMessage(e));
    } catch (e) {
      onError('حدث خطأ غير متوقع');
    }
  }

  /// ✅ تسجيل الدخول بجوجل عبر المتصفح الخارجي (Chrome).
  ///
  /// 1) بنفتح رابط الباك إند `/api/customers/google/redirect` بـ Chrome الخارجي.
  /// 2) المستخدم يسجل دخول بحساب جوجل على Chrome بشكل طبيعي.
  /// 3) بعد نجاح تسجيل الدخول، الباك إند بيعمل redirect لـ
  ///    `customerapp://auth?token=XXX` — أندرويد بيفتح التطبيق تلقائياً.
  /// 4) main.dart بيلتقط هاد الرابط وبيحفظ الـ token وبيروح على الـ HomeView.
  Future<void> loginWithGoogleExternal({
    required BuildContext context,
    required VoidCallback onLoading,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    onLoading();

    try {
      final googleAuthUrl = Uri.parse(
        '${ApiConstants.baseUrl}/api/customers/google/redirect',
      );

      final launched = await launchUrl(
        googleAuthUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        onError('تعذر فتح المتصفح، حاول مرة أخرى');
      }
      // إذا نجح الفتح، ما نعمل شي — main.dart بيتعامل مع الباقي
    } catch (e) {
      onError('حدث خطأ أثناء فتح المتصفح: $e');
    }
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }
}
