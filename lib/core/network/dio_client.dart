import 'package:customer_app/core/network/api_constants.dart';
import 'package:customer_app/core/utils/nav_utils.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

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
            onRequest: (options, handler) {
              // نبعت اللغة الحالية للتطبيق مع كل طلب (X-Locale)، عشان
              // الباك اند (middleware SetLocale) يرجّع رسائل الأخطاء/
              // الفاليديشن بنفس لغة الواجهة (ar/en).
              final locale =
                  navigatorKey.currentContext?.locale.languageCode ?? 'en';
              options.headers['X-Locale'] = locale;
              return handler.next(options);
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
      return e.response!.data['message'];
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
