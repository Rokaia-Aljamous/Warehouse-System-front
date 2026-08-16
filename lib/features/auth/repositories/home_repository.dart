import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/warehouse_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<List<WarehouseModel>> getWarehouses({
    required String token,
    String? search,
    String? type,
    String? governorate,
    String? companyName,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
        if (governorate != null && governorate.isNotEmpty)
          'governorate': governorate,
        if (companyName != null && companyName.isNotEmpty)
          'company_name': companyName,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final List data = response.data['warehouses'];
    return data.map((e) => WarehouseModel.fromJson(e)).toList();
  }
}
