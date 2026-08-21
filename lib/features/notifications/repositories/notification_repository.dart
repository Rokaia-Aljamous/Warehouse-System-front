import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

/// بيلعب نفس دور DriverNotificationService بتطبيق العامل، بس بنفس أسلوب
/// باقي الـ Repositories بهاد المشروع (CartRepository, HomeRepository...):
/// كل دالة بتاخد token صراحة وبتضيفه بـ Authorization header بنفسها،
/// بدل الاعتماد على Dio interceptor عام (المشروع ما مستخدم هيك حالياً).
class NotificationRepository {
  final Dio _dio = DioClient.instance;

  Options _authHeader(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<CustomerNotification>> getNotifications({
    required String token,
  }) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      options: _authHeader(token),
    );

    final rawNotifications = response.data is Map
        ? response.data['data']
        : null;

    if (rawNotifications is! List) return const [];

    return rawNotifications
        .whereType<Map>()
        .map(
          (item) =>
              CustomerNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<int> getUnreadCount({required String token}) async {
    final response = await _dio.get(
      ApiConstants.notificationUnreadCount,
      options: _authHeader(token),
    );

    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    return (body['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    await _dio.post(
      ApiConstants.notificationRead(notificationId),
      options: _authHeader(token),
    );
  }

  Future<void> markAllAsRead({required String token}) async {
    await _dio.post(
      ApiConstants.notificationReadAll,
      options: _authHeader(token),
    );
  }

  /// تسجيل الـ FCM device token تبع الزبون بالباك اند — بيحتاج التعديل
  /// الجديد بالباك (CustomerFirebaseTokenController + routes/customer.php).
  Future<void> registerDeviceToken({
    required String token,
    required String deviceToken,
    required String platform,
  }) async {
    await _dio.post(
      ApiConstants.notificationDeviceToken,
      data: {'token': deviceToken, 'platform': platform},
      options: _authHeader(token),
    );
  }

  Future<void> unregisterDeviceToken({
    required String token,
    required String deviceToken,
  }) async {
    await _dio.delete(
      ApiConstants.notificationDeviceToken,
      data: {'token': deviceToken},
      options: _authHeader(token),
    );
  }
}
