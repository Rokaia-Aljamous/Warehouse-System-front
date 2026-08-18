import 'package:geolocator/geolocator.dart';

/// نتيجة محاولة تحديد الموقع — إما إحداثيات، أو رسالة خطأ واضحة
/// للمستخدم (صلاحية مرفوضة / GPS مطفي / إلخ).
class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  const LocationResult.success({
    required this.latitude,
    required this.longitude,
  }) : errorMessage = null;

  const LocationResult.failure(this.errorMessage)
    : latitude = null,
      longitude = null;

  bool get isSuccess => errorMessage == null;
}

/// مسؤول عن طلب صلاحية الموقع من المستخدم، والتحقق من تفعيل GPS،
/// وجلب الإحداثيات الحالية (lat/lng) عشان نبعتها مع الطلبية للباك اند
/// (customer_latitude / customer_longitude)، يلي بدوره بيوصلها لتطبيق
/// السائق عشان يقدر يمشي عالخريطة لموقع الزبون.
class LocationHelper {
  LocationHelper._();

  /// يرجع [LocationResult] فيه الإحداثيات، أو رسالة خطأ جاهزة للعرض
  /// مباشرة بالواجهة (SnackBar / errorText) بدون ما تحتاجي تفسّريها.
  static Future<LocationResult> getCurrentLocation() async {
    // 1) تأكدي إنه خدمة الموقع (GPS) مفعّلة أصلاً عالجهاز
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.failure('location.service_disabled');
    }

    // 2) اطلبي/تحققي من صلاحية الموقع
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult.failure('location.permission_denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // المستخدم رفض نهائيًا (اختار "Don't ask again") — الحل الوحيد
      // هون إنه يفتح إعدادات التطبيق يدويًا ويفعّل الصلاحية من هناك.
      return const LocationResult.failure('location.permission_denied_forever');
    }

    // 3) جيبي الموقع الحالي فعليًا
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return const LocationResult.failure('location.fetch_failed');
    }
  }

  /// يفتح إعدادات التطبيق بالنظام (مفيدة لحالة deniedForever فوق).
  static Future<void> openAppSettings() => Geolocator.openAppSettings();
}
