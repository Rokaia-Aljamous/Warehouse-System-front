import 'package:customer_app/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';


class LoginController {
  final AuthRepository _repository = AuthRepository();

  final formKey      = GlobalKey<FormState>();
  final emailCtrl    = TextEditingController();
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
      onError(DioClient.getErrorMessage(e)); // ← هون التغيير الوحيد
    } catch (e) {
      onError('حدث خطأ غير متوقع');
    }
  }

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }
}