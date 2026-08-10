import 'package:customer_app/features/auth/models/warehouse_model.dart';
import 'package:customer_app/features/auth/repositories/home_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  // القائمة الكاملة كما وصلت من الـ API — لا تتغير بالبحث أو الفلترة.
  List<WarehouseModel> _allWarehouses = [];

  // القائمة المعروضة فعلياً (بعد البحث + الفلترة). الواجهة تقرأ من هون.
  List<WarehouseModel> warehouses = [];

  bool isLoading = false;
  String? errorMessage;

  String _searchQuery = '';
  String? _governorateFilter; // null = All
  String? _typeFilter; // نص جزئي على حقل النوع، فاضي/null = All

  String? get governorateFilter => _governorateFilter;
  String? get typeFilter => _typeFilter;

  /// قائمة المحافظات الحقيقية الموجودة فعلياً بالمستودعات المحمّلة (بدون تكرار)،
  /// تُستخدم لملء نافذة الفلترة بخيارات حقيقية بدل قيمة ثابتة وهمية.
  List<String> get availableGovernorates =>
      _allWarehouses
          .map((w) => w.governorate)
          .where((g) => g.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();

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
      _applyFilters();
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
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// يستدعى من نافذة الفلترة (Filter Dialog) بعد ما يضغط المستخدم "Apply Filters".
  /// governorate: null أو فاضي = بدون فلترة محافظة (الكل).
  /// type: null أو فاضي = بدون فلترة نوع (الكل).
  void applyFilters({String? governorate, String? type}) {
    _governorateFilter = (governorate == null || governorate.trim().isEmpty)
        ? null
        : governorate;
    _typeFilter = (type == null || type.trim().isEmpty) ? null : type.trim();
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _governorateFilter = null;
    _typeFilter = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();
    final typeQuery = _typeFilter?.toLowerCase();

    warehouses = _allWarehouses.where((w) {
      final matchesSearch =
          q.isEmpty ||
          w.warehouseName.toLowerCase().contains(q) ||
          w.location.toLowerCase().contains(q) ||
          w.governorate.toLowerCase().contains(q) ||
          w.type.toLowerCase().contains(q);

      final matchesGovernorate =
          _governorateFilter == null || w.governorate == _governorateFilter;

      final matchesType =
          typeQuery == null || w.type.toLowerCase().contains(typeQuery);

      return matchesSearch && matchesGovernorate && matchesType;
    }).toList();
  }
}
