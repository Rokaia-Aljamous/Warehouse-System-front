import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio = DioClient.instance;

  Future<List<ProductModel>> getProducts({
    required String token,
    required int warehouseId,
    String? search,
    String? brand,
    String? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/products',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (type != null && type.isNotEmpty) 'type': type,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final List data = response.data['products'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct({
    required String token,
    required int warehouseId,
    required int productId,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/products/$productId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ProductModel.fromJson(response.data['product']);
  }
}
