import 'package:customer_app/features/auth/models/warehouse_model.dart';
import 'package:customer_app/features/auth/repositories/home_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';


class HomeController extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  // القائمة الكاملة كما وصلت من الـ API — لا تتغير بالبحث.
  List<WarehouseModel> _allWarehouses = [];

  // القائمة المعروضة فعلياً (بعد الفلترة). الواجهة تقرأ من هون.
  List<WarehouseModel> warehouses = [];

  bool isLoading = false;
  String? errorMessage;
  String _searchQuery = '';

  Future<void> loadWarehouses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'غير مسجل الدخول';
        return;
      }

      _allWarehouses = await _repository.getWarehouses(token: token);
      _applySearch();
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
    } catch (e) {
      errorMessage = 'حدث خطأ غير متوقع';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// يستدعى كل ما يكتب المستخدم بحقل البحث.
  /// فلترة محلية على اسم المستودع / الموقع / المحافظة / النوع.
  void search(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      warehouses = _allWarehouses;
      return;
    }
    warehouses = _allWarehouses.where((w) {
      return w.warehouseName.toLowerCase().contains(q) ||
          w.location.toLowerCase().contains(q) ||
          w.governorate.toLowerCase().contains(q) ||
          w.type.toLowerCase().contains(q);
    }).toList();
  }
}