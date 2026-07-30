/// عنصر داخل الطلب (منتج + كمية + سعر وقت الطلب).
class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse_id'] ?? 0,
      status: json['status'] ?? 'pending',
      totalPrice: double.tryParse('${json['total_price']}') ?? 0.0,
      orderDate:
          DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      customerLocation: json['customer_location'] ?? '',
      orderQrCode: json['order_qr_code'] ?? '',
      transferAssignment: json['transfer_assignment'] != null
          ? double.tryParse('${json['transfer_assignment']}')
          : null,
      itemsCount: json['items_count'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
