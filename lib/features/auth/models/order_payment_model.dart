/// نتيجة محاولة دفع PayPal لطلبية — يطابق شكل OrderPaymentResource بالباك اند.
/// (id, order_id, provider, payment_method, paypal_order_id, paypal_capture_id,
///  approval_url, amount, currency, status, failure_reason, paid_at)
class OrderPaymentModel {
  final int id;
  final int orderId;
  final String provider;
  final String? paymentMethod;
  final String? paypalOrderId;
  final String? paypalCaptureId;

  /// رابط صفحة الدفع تبع PayPal — موجود بعد createPayPalOrder فقط،
  /// وبيصير null بعد ما يتم capture الدفعة.
  final String? approvalUrl;

  final double amount;
  final String currency;

  /// created | processing | completed | failed | cancelled
  final String status;
  final String? failureReason;
  final DateTime? paidAt;

  OrderPaymentModel({
    required this.id,
    required this.orderId,
    required this.provider,
    this.paymentMethod,
    this.paypalOrderId,
    this.paypalCaptureId,
    this.approvalUrl,
    required this.amount,
    required this.currency,
    required this.status,
    this.failureReason,
    this.paidAt,
  });

  bool get isCompleted => status == 'completed';

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      provider: json['provider'] ?? 'paypal',
      paymentMethod: json['payment_method'],
      paypalOrderId: json['paypal_order_id'],
      paypalCaptureId: json['paypal_capture_id'],
      approvalUrl: json['approval_url'],
      amount: double.tryParse('${json['amount']}') ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'created',
      failureReason: json['failure_reason'],
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
    );
  }
}
