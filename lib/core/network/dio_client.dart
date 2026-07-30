import 'package:customer_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';


/// كل إعدادات Dio + معالجة الأخطاء بمكان واحد
class DioClient {
  DioClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true), // ← بيطبع كل شي بالـ console تلقائياً، بلا ما تكتب أي debugPrint
    );

  static Dio get instance => _dio;

  /// يحوّل أي خطأ Dio لرسالة نص واضحة + الأخطاء التفصيلية (validation)
  static String getErrorMessage(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'تأكد من اتصالك بالإنترنت';
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }

  /// يرجع أخطاء الـ validation تبعت Laravel (لو موجودة)
  static Map<String, dynamic>? getFieldErrors(DioException e) {
    if (e.response?.data is Map && e.response?.data['errors'] != null) {
      return e.response!.data['errors'];
    }
    return null;
  }
}