import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/order_model.dart';
import '../features/auth/repositories/order_repository.dart';

/// يدير حالة شاشة "طلباتي": تحميل القائمة (مع فلترة اختيارية حسب الحالة).
class OrdersController extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> orders = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadOrders({String? status}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return;
      }
      orders = await _repository.getOrders(token: token, status: status);
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
    } catch (e) {
      errorMessage = 'errors.orders_load_failed'.tr();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// يجيب تفاصيل طلبية واحدة (مع الـ items والـ order_qr_code) من الباك اند مباشرة.
  /// GET /api/customers/orders/{id}
  Future<OrderModel?> fetchOrderDetails(int orderId) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;
    return _repository.getOrderDetails(token: token, orderId: orderId);
  }

  /// يرسل التعديلات (كميات/حذف) للباك اند. برجّع الطلبية المحدّثة لو نجحت، أو null لو فشلت.
  Future<OrderModel?> updateOrderItems({
    required int orderId,
    required List<Map<String, int>> items,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;
      return await _repository.updateOrderItems(
        token: token,
        orderId: orderId,
        items: items,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return false;
      final updated = await _repository.cancelOrder(
        token: token,
        orderId: orderId,
      );
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) orders[index] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
