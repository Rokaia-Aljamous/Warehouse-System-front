import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  Future<OrderModel> placeOrder({
    required String token,
    required int warehouseId,
    required String customerLocation,
  }) async {
    final response = await _dio.post(
      '/api/customers/warehouses/$warehouseId/orders',
      data: {'customer_location': customerLocation},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderModel.fromJson(response.data['order']);
  }

  Future<List<OrderModel>> getOrders({
    required String token,
    String? status,
  }) async {
    final response = await _dio.get(
      '/api/customers/orders',
      queryParameters: status != null ? {'status': status} : null,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final List data = response.data['orders'];
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderDetails({
    required String token,
    required int orderId,
  }) async {
    final response = await _dio.get(
      '/api/customers/orders/$orderId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderModel.fromJson(response.data['order']);
  }

  /// يعدّل قائمة منتجات الطلبية (كميات/حذف/إضافة) — PATCH /api/customers/orders/{id}
  /// items: قائمة بكل عنصر لازم يبقى بالطلبية بعد التعديل، مثلاً:
  /// [{'product_id': 5, 'quantity': 3}, {'product_id': 8, 'quantity': 1}]
  Future<OrderModel> updateOrderItems({
    required String token,
    required int orderId,
    required List<Map<String, int>> items,
  }) async {
    final response = await _dio.patch(
      '/api/customers/orders/$orderId',
      data: {'items': items},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderModel.fromJson(response.data['order']);
  }

  Future<OrderModel> cancelOrder({
    required String token,
    required int orderId,
  }) async {
    final response = await _dio.post(
      '/api/customers/orders/$orderId/cancel',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderModel.fromJson(response.data['order']);
  }
}
