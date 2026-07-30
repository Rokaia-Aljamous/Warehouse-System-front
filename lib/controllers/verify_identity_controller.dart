import 'package:customer_app/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';

class VerifyIdentityController {
  final AuthRepository _repository = AuthRepository();
  final pinCtrl = TextEditingController();

  // ── تحقق إذا الإيميل اتأكد ──────────────────────────────
  Future<bool> checkVerification({required String email}) async {
    try {
      final response = await DioClient.instance.get(
        '/api/customers/check-verification',
        queryParameters: {'email': email},
      );
      return response.data['verified'] == true;
    } catch (e) {
      return false;
    }
  }

  // ── إعادة إرسال الإيميل ──────────────────────────────────
  Future<void> resendCode({
    required String email,
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    try {
      await _repository.forgotPassword(email: email);
      onSuccess();
    } on DioException catch (e) {
      onError(DioClient.getErrorMessage(e));
    } catch (e) {
      onError('حدث خطأ غير متوقع');
    }
  }

  void dispose() => pinCtrl.dispose();
}
