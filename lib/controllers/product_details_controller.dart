import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/models/cart_model.dart';
import '../features/auth/models/product_model.dart';
import '../features/auth/repositories/cart_repository.dart';
import '../features/auth/repositories/product_repository.dart';

/// يدير حالة شاشة "تفاصيل المنتج": جلب بيانات منتج واحد + إضافته للسلة.
class ProductDetailsController extends ChangeNotifier {
  final int warehouseId;
  final int productId;
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository();

  ProductDetailsController({
    required this.warehouseId,
    required this.productId,
  });

  ProductModel? product;
  bool isLoading = false;
  String? errorMessage;

  bool isAddingToCart = false;
  String? cartError;
  CartModel? cart;

  Future<void> loadProduct() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return;
      }
      product = await _productRepository.getProduct(
        token: token,
        warehouseId: warehouseId,
        productId: productId,
      );
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
    } catch (e) {
      errorMessage = 'errors.product_load_failed'.tr();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({required int quantity}) async {
    isAddingToCart = true;
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
      isAddingToCart = false;
      notifyListeners();
    }
  }
}
