import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/return_model.dart';

class ReturnRepository {
  final Dio _dio = DioClient.instance;

  /// GET /api/customers/returns
  /// category (اختياري): pending | approved | rejected — نفس ما بيدعمه الباك اند.
  /// إذا ما انبعتت، بيرجع كل المرتجعات (وقتها منصنّفهم محلياً بالتطبيق).
  Future<List<ReturnModel>> getReturns({
    required String token,
    String? category,
  }) async {
    final response = await _dio.get(
      '/api/customers/returns',
      queryParameters: category != null ? {'category': category} : null,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final List data = response.data['returns'];
    return data.map((e) => ReturnModel.fromJson(e)).toList();
  }

  /// GET /api/customers/returns/{id}
  Future<ReturnModel> getReturnDetails({
    required String token,
    required int returnId,
  }) async {
    final response = await _dio.get(
      '/api/customers/returns/$returnId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ReturnModel.fromJson(response.data['return']);
  }

  /// POST /api/customers/orders/{order}/returns
  /// items: قائمة بالعناصر المطلوب إرجاعها [{'order_item_id': x, 'quantity': y}, ...]
  /// لو تركتها فاضية، الباك اند بيرجّع كل العناصر المتبقية بالطلبية تلقائياً.
  Future<ReturnModel> createReturn({
    required String token,
    required int orderId,
    required String returnReason,
    List<Map<String, int>> items = const [],
  }) async {
    final response = await _dio.post(
      '/api/customers/orders/$orderId/returns',
      data: {
        'return_reason': returnReason,
        if (items.isNotEmpty) 'items': items,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ReturnModel.fromJson(response.data['return']);
  }

  /// POST /api/customers/returns/{id}/cancel
  Future<ReturnModel> cancelReturn({
    required String token,
    required int returnId,
  }) async {
    final response = await _dio.post(
      '/api/customers/returns/$returnId/cancel',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ReturnModel.fromJson(response.data['return']);
  }
}
