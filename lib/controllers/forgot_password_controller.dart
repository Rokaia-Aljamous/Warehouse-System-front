import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import 'package:customer_app/features/auth/repositories/auth_repository.dart';

class ForgotPasswordController {
  final AuthRepository _repository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();

  Future<void> sendCode({
    required VoidCallback onLoading,
    required void Function(String email) onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    onLoading();

    try {
      await _repository.forgotPassword(email: emailCtrl.text.trim());
      onSuccess(emailCtrl.text.trim());
    } on DioException catch (e) {
      onError(DioClient.getErrorMessage(e));
    } catch (e) {
      onError('errors.unexpected'.tr());
    }
  }

  void dispose() => emailCtrl.dispose();
}
