import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/order_payment_model.dart';

/// نداءات الدفع عبر PayPal — تستخدم endpoints الموجودة فعلياً بالباك اند
/// (CustomerOrderPaymentController) بدون أي تعديل عليها.
class OrderPaymentRepository {
  final Dio _dio = DioClient.instance;

  /// روابط "نجاح/إلغاء" وهمية نبعتها كـ return_url و cancel_url.
  ///
  /// لازم تكونوا https صحيحين (متطلب من PayPal نفسه لصفحة الدفع)، بس
  /// التطبيق ما بيخليهم يتحمّلوا فعلياً أبداً — شاشة الـ WebView
  /// (PayPalWebViewView) بتعترض أي محاولة تنقّل تبلّش بهاد الرابط،
  /// تستخرج منها paypal_order_id، وتسكر نفسها. يعني ما في داعي لأي
  /// deep link scheme أو تعديل بالباك اند.
  static const String successRedirectPrefix =
      'https://payment.customer-app.local/success';
  static const String cancelRedirectPrefix =
      'https://payment.customer-app.local/cancel';

  /// POST /api/customers/orders/{order}/payments/paypal/create
  /// بيرجع OrderPaymentModel فيه approval_url — هاد هو رابط صفحة PayPal.
  Future<OrderPaymentModel> createPayPalOrder({
    required String token,
    required int orderId,
  }) async {
    final response = await _dio.post(
      '/api/customers/orders/$orderId/payments/paypal/create',
      data: {
        'return_url': successRedirectPrefix,
        'cancel_url': cancelRedirectPrefix,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderPaymentModel.fromJson(response.data['payment']);
  }

  /// POST /api/customers/orders/{order}/payments/paypal/capture
  /// بينادى بعد ما الزبون يوافق بصفحة PayPal ونرجع نمسك paypal_order_id
  /// من رابط النجاح.
  Future<OrderPaymentModel> capturePayPalOrder({
    required String token,
    required int orderId,
    required String paypalOrderId,
  }) async {
    final response = await _dio.post(
      '/api/customers/orders/$orderId/payments/paypal/capture',
      data: {'paypal_order_id': paypalOrderId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderPaymentModel.fromJson(response.data['payment']);
  }

  /// GET /api/customers/orders/{order}/payments
  /// استرجاع محاولات الدفع السابقة لهاد الطلب، مرتبة من الأحدث للأقدم.
  ///
  /// تستخدم للـ recovery: لو التطبيق انسكر أو خرج المستخدم للمتصفح
  /// وضاعت قيمة paypal_order_id المحفوظة محلياً، أو لو بدك تتأكدي قبل
  /// ما تبلّشي create جديد إنه ما في محاولة created/processing سابقة
  /// على نفس الطلب (لتفادي 409 processing).
  Future<List<OrderPaymentModel>> getPaymentAttempts({
    required String token,
    required int orderId,
  }) async {
    final response = await _dio.get(
      '/api/customers/orders/$orderId/payments',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final list = response.data['payments'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
