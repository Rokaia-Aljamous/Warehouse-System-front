import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

class CartRepository {
  final Dio _dio = DioClient.instance;

  Future<CartModel> getCart({
    required String token,
    required int warehouseId,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/cart',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final cartJson = response.data['cart'];
    return cartJson == null
        ? CartModel.empty(warehouseId)
        : CartModel.fromJson(cartJson);
  }

  Future<CartModel> addItem({
    required String token,
    required int warehouseId,
    required int productId,
    required int quantity,
  }) async {
    final response = await _dio.post(
      '/api/customers/warehouses/$warehouseId/cart/items',
      data: {'product_id': productId, 'quantity': quantity},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return CartModel.fromJson(response.data['cart']);
  }

  Future<CartModel> updateItem({
    required String token,
    required int warehouseId,
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await _dio.patch(
      '/api/customers/warehouses/$warehouseId/cart/items/$cartItemId',
      data: {'quantity': quantity},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return CartModel.fromJson(response.data['cart']);
  }

  Future<CartModel> removeItem({
    required String token,
    required int warehouseId,
    required int cartItemId,
  }) async {
    final response = await _dio.delete(
      '/api/customers/warehouses/$warehouseId/cart/items/$cartItemId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return CartModel.fromJson(response.data['cart']);
  }
}
