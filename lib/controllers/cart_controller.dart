import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/cart_model.dart';
import '../features/auth/models/order_model.dart';
import '../features/auth/repositories/cart_repository.dart';
import '../features/auth/repositories/order_repository.dart';

/// يدير حالة شاشة "سلتي" الخاصة بمستودع محدد: عرض/تعديل/حذف عناصر السلة،
/// وإنشاء الطلب النهائي (Checkout).
class CartController extends ChangeNotifier {
  final int warehouseId;
  final CartRepository _cartRepository = CartRepository();
  final OrderRepository _orderRepository = OrderRepository();

  CartController({required this.warehouseId});

  CartModel? cart;
  bool isLoading = false;
  String? errorMessage;

  bool isPlacingOrder = false;
  String? orderError;
  OrderModel? lastPlacedOrder;

  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return;
      }
      cart = await _cartRepository.getCart(
        token: token,
        warehouseId: warehouseId,
      );
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
    } catch (e) {
      errorMessage = 'errors.cart_load_failed'.tr();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) return;
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;
      cart = await _cartRepository.updateItem(
        token: token,
        warehouseId: warehouseId,
        cartItemId: cartItemId,
        quantity: quantity,
      );
      notifyListeners();
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;
      cart = await _cartRepository.removeItem(
        token: token,
        warehouseId: warehouseId,
        cartItemId: cartItemId,
      );
      notifyListeners();
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      notifyListeners();
    }
  }

  /// بينشئ الطلب النهائي من السلة الحالية. بيرجع true لو نجح.
  Future<bool> placeOrder(String customerLocation) async {
    isPlacingOrder = true;
    orderError = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        orderError = 'errors.not_logged_in'.tr();
        return false;
      }
      lastPlacedOrder = await _orderRepository.placeOrder(
        token: token,
        warehouseId: warehouseId,
        customerLocation: customerLocation,
      );
      // السلة بتنمسح تلقائيًا بالباكيند بعد إنشاء الطلب، فنفرّغها محليًا كمان.
      cart = CartModel.empty(warehouseId);
      return true;
    } on DioException catch (e) {
      orderError = DioClient.getErrorMessage(e);
      return false;
    } catch (e) {
      orderError = 'errors.order_failed'.tr();
      return false;
    } finally {
      isPlacingOrder = false;
      notifyListeners();
    }
  }
}
