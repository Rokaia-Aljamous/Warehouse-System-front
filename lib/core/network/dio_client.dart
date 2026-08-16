import 'package:customer_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../storage/token_storage.dart';

/// كل إعدادات Dio + معالجة الأخطاء بمكان واحد
class DioClient {
  DioClient._();

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 45),
            receiveTimeout: const Duration(seconds: 45),
            headers: {'Accept': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers.putIfAbsent(
                  'Authorization',
                  () => 'Bearer $token',
                );
              }
              handler.next(options);
            },
            onError: (error, handler) async {
              if (error.response?.statusCode == 401) {
                await TokenStorage.clearToken();
              }
              handler.next(error);
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
          ), // ← بيطبع كل شي بالـ console تلقائياً، بلا ما تكتب أي debugPrint
        );

  static Dio get instance => _dio;

  /// يحوّل أي خطأ Dio لرسالة نص واضحة + الأخطاء التفصيلية (validation)
  static String getErrorMessage(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'errors.no_internet'.tr();
    }
    return 'common.error_generic'.tr();
  }

  /// يرجع أخطاء الـ validation تبعت Laravel (لو موجودة)
  static Map<String, dynamic>? getFieldErrors(DioException e) {
    if (e.response?.data is Map && e.response?.data['errors'] != null) {
      return e.response!.data['errors'];
    }
    return null;
  }
}
