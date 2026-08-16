import 'package:customer_app/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';

class CreatePasswordController {
  final AuthRepository _repository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  Future<void> resetPassword({
    required String email,
    required String token,
    required VoidCallback onLoading,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    onLoading();

    try {
      await _repository.resetPassword(
        token: token,
        email: email,
        password: newPassCtrl.text,
        passwordConfirmation: confirmPassCtrl.text,
      );
      onSuccess();
    } on DioException catch (e) {
      onError(DioClient.getErrorMessage(e));
    } catch (e) {
      onError('errors.unexpected'.tr());
    }
  }

  void dispose() {
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
  }
}
