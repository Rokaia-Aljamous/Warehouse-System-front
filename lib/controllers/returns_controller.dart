import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../features/return/models/return_model.dart';
import '../features/return/repositories/return_repository.dart';

/// يدير حالة شاشات "مرتجعاتي": تحميل القائمة، تفاصيل مرتجع، إنشاء وإلغاء مرتجع.
class ReturnsController extends ChangeNotifier {
  final ReturnRepository _repository = ReturnRepository();

  List<ReturnModel> returns = [];
  bool isLoading = false;
  String? errorMessage;

  /// بيجيب كل المرتجعات (بدون فلترة بالباك اند) عشان نقدر نصنّفهم محلياً
  /// على 3 تابات: Pending / In Progress / Archived (uiCategory بموديل الإرجاع).
  Future<void> loadReturns() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return;
      }
      returns = await _repository.getReturns(token: token);
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
    } catch (e) {
      errorMessage = 'errors.returns_load_failed'.tr();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ReturnModel> byCategory(ReturnUiCategory category) =>
      returns.where((r) => r.uiCategory == category).toList();

  Future<ReturnModel?> fetchReturnDetails(int returnId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;
      return await _repository.getReturnDetails(
        token: token,
        returnId: returnId,
      );
    } catch (_) {
      return null;
    }
  }

  /// بيقدّم طلب إرجاع جديد لطلبية مسلَّمة (delivered).
  /// بيرجّع الـ ReturnModel الجديد لو نجح، أو null لو فشل (و errorMessage بيتعبّى).
  Future<ReturnModel?> submitReturn({
    required int orderId,
    required String returnReason,
    List<Map<String, int>> items = const [],
  }) async {
    errorMessage = null;
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        errorMessage = 'errors.not_logged_in'.tr();
        return null;
      }
      final created = await _repository.createReturn(
        token: token,
        orderId: orderId,
        returnReason: returnReason,
        items: items,
      );
      returns = [created, ...returns];
      notifyListeners();
      return created;
    } on DioException catch (e) {
      errorMessage = DioClient.getErrorMessage(e);
      return null;
    } catch (e) {
      errorMessage = 'errors.return_submit_failed'.tr();
      return null;
    }
  }

  Future<bool> cancelReturn(int returnId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return false;
      final updated = await _repository.cancelReturn(
        token: token,
        returnId: returnId,
      );
      final index = returns.indexWhere((r) => r.id == returnId);
      if (index != -1) returns[index] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
