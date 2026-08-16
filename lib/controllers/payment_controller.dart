import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/order_payment_model.dart';
import '../features/auth/repositories/order_payment_repository.dart';

/// يدير حالة عملية دفع طلبية عبر PayPal: بدء الجلسة، وتأكيدها بعد
/// ما الزبون يوافق بصفحة PayPal.
class PaymentController extends ChangeNotifier {
  final OrderPaymentRepository _repository = OrderPaymentRepository();

  bool isLoading = false;
  String? errorMessage;
  OrderPaymentModel? payment;

  /// بيبلّش جلسة دفع جديدة (أو يرجّع الجلسة الحالية لو موجودة). برجّع
  /// null لو صار خطأ — errorMessage عندها بيكون فيه سبب الفشل.
  Future<OrderPaymentModel?> startPayPalPayment(int orderId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return null;
      }

      payment = await _repository.createPayPalOrder(
        token: token,
        orderId: orderId,
      );
      return payment;
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      return null;
    } catch (_) {
      errorMessage = 'common.error_generic'.tr();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// بيرجع محاولات الدفع السابقة لطلب معيّن (GET .../payments).
  /// بترجع لستة فاضية لو صار خطأ — errorMessage بيتعبّى بسبب الفشل.
  Future<List<OrderPaymentModel>> fetchPaymentAttempts(int orderId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return [];
      }
      return await _repository.getPaymentAttempts(
        token: token,
        orderId: orderId,
      );
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      return [];
    } catch (_) {
      errorMessage = 'common.error_generic'.tr();
      return [];
    }
  }

  /// بيأكد الدفع بعد موافقة الزبون بصفحة PayPal (capture).
  Future<OrderPaymentModel?> confirmPayPalPayment({
    required int orderId,
    required String paypalOrderId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return null;
      }

      payment = await _repository.capturePayPalOrder(
        token: token,
        orderId: orderId,
        paypalOrderId: paypalOrderId,
      );
      return payment;
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      return null;
    } catch (_) {
      errorMessage = 'common.error_generic'.tr();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
