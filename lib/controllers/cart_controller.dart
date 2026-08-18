import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/cart_model.dart';
import '../features/auth/models/order_model.dart';
import '../features/auth/repositories/cart_repository.dart';
import '../features/auth/repositories/order_repository.dart';
import '../features/auth/repositories/product_repository.dart';

/// يدير حالة شاشة "سلتي" الخاصة بمستودع محدد: عرض/تعديل/حذف عناصر السلة،
/// وإنشاء الطلب النهائي (Checkout).
class CartController extends ChangeNotifier {
  final int warehouseId;
  final CartRepository _cartRepository = CartRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();

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
      await _enrichCartImages(token);
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
      await _enrichCartImages(token);
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
      await _enrichCartImages(token);
      notifyListeners();
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      notifyListeners();
    }
  }

  /// بينشئ الطلب النهائي من السلة الحالية. بيرجع true لو نجح.
  Future<bool> placeOrder(
    String customerLocation, {
    required String deliveryRegion,
    required double latitude,
    required double longitude,
  }) async {
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
        deliveryRegion: deliveryRegion,
        latitude: latitude,
        longitude: longitude,
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

  /// تعبئة صور عناصر السلة محليًا (frontend-side image enrichment).
  ///
  /// الباك اند حاليًا ما بيرجّع main_image ضمن رد السلة (CartItemResource
  /// الأصلي ما فيه هاد الحقل)، فبنجيب صورة كل منتج ناقصة صورته عبر
  /// endpoint المنتج الفردي (يلي أصلاً بيرجّعها صح) — وهاد الـ endpoint
  /// نفسه مزوّد بكاش داخل ProductRepository، فما منكرر نفس الطلب لنفس
  /// المنتج أكتر من مرة بالجلسة الواحدة.
  ///
  /// ما منوقف تحميل السلة لو فشل جلب صورة معينة — بترجع null بهدوء
  /// وبتضل بس الصورة الاحتياطية (fallback) ظاهرة لهاد العنصر تحديداً.
  Future<void> _enrichCartImages(String token) async {
    final currentCart = cart;
    if (currentCart == null || currentCart.items.isEmpty) return;

    final itemsNeedingImage = currentCart.items
        .where((item) => item.mainImage == null || item.mainImage!.isEmpty)
        .toList();
    if (itemsNeedingImage.isEmpty) return;

    await Future.wait(
      itemsNeedingImage.map((item) async {
        final image = await _productRepository.getProductImage(
          token: token,
          warehouseId: warehouseId,
          productId: item.productId,
        );
        if (image == null || image.isEmpty) return;
        final index = currentCart.items.indexWhere((e) => e.id == item.id);
        if (index == -1) return;
        currentCart.items[index] = currentCart.items[index].copyWith(
          mainImage: image,
        );
      }),
    );
  }
}
