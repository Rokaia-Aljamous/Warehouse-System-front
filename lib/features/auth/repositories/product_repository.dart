import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio = DioClient.instance;

  Future<List<ProductModel>> getProducts({
    required String token,
    required int warehouseId,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/products',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final List data = response.data['products'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}
