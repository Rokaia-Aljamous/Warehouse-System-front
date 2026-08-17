/// عنصر داخل الطلب (منتج + كمية + سعر وقت الطلب).
class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  /// رابط صورة المنتج — الباك اند ما بيرجعها ضمن ردود الطلبات، فبتنعبى
  /// محليًا بالفلاتر (frontend enrichment) عبر ProductRepository.getProductImage.
  final String? mainImage;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.mainImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse('${json['unit_price']}') ?? 0.0,
      subtotal: double.tryParse('${json['subtotal']}') ?? 0.0,
    );
  }

  OrderItemModel copyWith({String? mainImage}) {
    return OrderItemModel(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      mainImage: mainImage ?? this.mainImage,
    );
  }
}

/// الطلب — يستخدم لعرض القائمة (بدون items) وللتفاصيل (مع items).
/// GET /api/customers/orders            → قائمة (بدون items)
/// GET /api/customers/orders/{id}       → تفاصيل (مع items)
/// POST /api/customers/warehouses/{id}/orders → إنشاء طلب جديد
class OrderModel {
  final int id;
  final int warehouseId;
  final String status; // pending | approved | delivered | rejected | cancelled
  final double totalPrice;
  final DateTime orderDate;
  final String customerLocation;
  final String orderQrCode;
  final double? transferAssignment;
  final int? itemsCount;
  final List<OrderItemModel> items;

  /// not_started | pending | processing | paid | failed
  /// (راجع "قواعد مهمة قبل الربط" بدليل PayPal — هاد الحقل هو المرجع
  /// الوحيد لمعرفة إذا الطلب مدفوع فعلاً، مش مجرد الرجوع من صفحة PayPal).
  final String? paymentStatus;

  /// true فقط لما يصير مسموح تبلّشي جلسة دفع جديدة لهاد الطلب.
  /// يصير false تلقائياً بعد نجاح الدفع — هو المرجع الوحيد لإظهار/إخفاء
  /// زر "Pay Now"، مش status الطلب لحاله.
  final bool canPay;

  final bool canPrepare;

  OrderModel({
    required this.id,
    required this.warehouseId,
    required this.status,
    required this.totalPrice,
    required this.orderDate,
    required this.customerLocation,
    required this.orderQrCode,
    this.transferAssignment,
    this.itemsCount,
    this.items = const [],
    this.paymentStatus,
    this.canPay = false,
    this.canPrepare = false,
  });

  /// الطلب "مدفوع" فقط لما الحالة تكون paid صراحة من الباك اند.
  bool get isPaid => paymentStatus == 'paid';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse_id'] ?? 0,
      status: json['status'] ?? 'pending',
      totalPrice: double.tryParse('${json['total_price']}') ?? 0.0,
      orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      customerLocation: json['customer_location'] ?? '',
      orderQrCode: json['order_qr_code'] ?? '',
      transferAssignment: json['transfer_assignment'] != null
          ? double.tryParse('${json['transfer_assignment']}')
          : null,
      itemsCount: json['items_count'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentStatus: json['payment_status'],
      canPay: json['can_pay'] == true,
      canPrepare: json['can_prepare'] == true,
    );
  }

  /// بيرجع نسخة جديدة من نفس الطلب لكن بقائمة items مختلفة — تستخدم
  /// بعد تعبئة صور المنتجات محليًا (frontend image enrichment) بدون
  /// ما نحتاج نعيد بناء كل حقول OrderModel يدويًا بكل مرة.
  OrderModel copyWithItems(List<OrderItemModel> items) {
    return OrderModel(
      id: id,
      warehouseId: warehouseId,
      status: status,
      totalPrice: totalPrice,
      orderDate: orderDate,
      customerLocation: customerLocation,
      orderQrCode: orderQrCode,
      transferAssignment: transferAssignment,
      itemsCount: itemsCount,
      items: items,
      paymentStatus: paymentStatus,
      canPay: canPay,
      canPrepare: canPrepare,
    );
  }
}
