import 'package:customer_app/core/network/dio_client.dart';
import 'package:customer_app/core/utils/phone_utils.dart';
import 'package:customer_app/features/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RegisterController {
  final AuthRepository _repository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final birthdayCtrl =
      TextEditingController(); // يُملأ بصيغة yyyy-MM-dd للـ API
  final displayBirthdayCtrl =
      TextEditingController(); // يُملأ بصيغة day/month/year للعرض فقط
  final locationCtrl = TextEditingController();

  Future<void> register({
    required BuildContext context,
    required VoidCallback onLoading,
    required void Function(String email) onSuccess,
    required void Function(String message, Map<String, dynamic>? fieldErrors)
    onError,
  }) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    onLoading();

    try {
      await _repository.register(
        fullName: fullNameCtrl.text.trim(),
        birthday: birthdayCtrl.text.trim(),
        // الباك اند صار يشترط صيغة دولية كاملة (+963...) بدل الصيغة
        // المحلية القديمة (9xxxxxxxx)، فمنطبّعها هون قبل الإرسال.
        phoneNumber: PhoneUtils.normalizeSyrianPhone(phoneCtrl.text.trim()),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        passwordConfirmation: confirmPasswordCtrl.text,
      );

      onSuccess(emailCtrl.text.trim());
    } on DioException catch (e) {
      onError(DioClient.getErrorMessage(e), DioClient.getFieldErrors(e));
    } catch (e) {
      onError('errors.unexpected_with_detail'.tr(args: [e.toString()]), null);
    }
  }

  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    birthdayCtrl.dispose();
    displayBirthdayCtrl.dispose();
    locationCtrl.dispose();
  }
}
