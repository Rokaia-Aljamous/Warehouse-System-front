import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/cart_model.dart';
import '../features/auth/models/product_model.dart';
import '../features/auth/repositories/cart_repository.dart';
import '../features/auth/repositories/product_repository.dart';

/// يدير حالة شاشة "تفاصيل المستودع": المنتجات + سلة هاد المستودع.
class WarehouseDetailsController extends ChangeNotifier {
  final int warehouseId;
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository();

  WarehouseDetailsController({required this.warehouseId});

  List<ProductModel> products = [];
  CartModel? cart;

  bool isLoadingProducts = false;
  String? productsError;

  bool isCartBusy = false;
  String? cartError;

  Future<void> loadAll() async {
    await Future.wait([loadProducts(), loadCart()]);
  }

  Future<void> loadProducts() async {
    isLoadingProducts = true;
    productsError = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        productsError = 'errors.not_logged_in'.tr();
        return;
      }
      products = await _productRepository.getProducts(
        token: token,
        warehouseId: warehouseId,
      );
    } on DioException catch (e) {
      productsError = DioClient.getErrorMessage(e);
    } catch (e) {
      productsError = 'errors.products_load_failed'.tr();
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;
      cart = await _cartRepository.getCart(
        token: token,
        warehouseId: warehouseId,
      );
      notifyListeners();
    } catch (_) {
      // فشل تحميل السلة بالخلفية ما لازم يوقف عرض المنتجات — نتجاهله بصمت.
    }
  }

  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    isCartBusy = true;
    cartError = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        cartError = 'errors.not_logged_in'.tr();
        return false;
      }
      cart = await _cartRepository.addItem(
        token: token,
        warehouseId: warehouseId,
        productId: productId,
        quantity: quantity,
      );
      return true;
    } on DioException catch (e) {
      cartError = DioClient.getErrorMessage(e);
      return false;
    } catch (e) {
      cartError = 'errors.add_to_cart_failed'.tr();
      return false;
    } finally {
      isCartBusy = false;
      notifyListeners();
    }
  }
}
