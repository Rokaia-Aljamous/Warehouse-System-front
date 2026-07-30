import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/warehouse_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<List<WarehouseModel>> getWarehouses({required String token}) async {
    final response = await _dio.get(
      '/api/customers/warehouses',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final List data = response.data['warehouses'];
    return data.map((e) => WarehouseModel.fromJson(e)).toList();
  }
}