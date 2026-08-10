/// عنصر داخل طلب الإرجاع (منتج + كمية + سعر).
class ReturnItemModel {
  final int id;
  final int quantity;
  final int productId;
  final String productName;
  final double unitPrice;
  final double subtotal;

  ReturnItemModel({
    required this.id,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.subtotal,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return ReturnItemModel(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productId: product['id'] ?? 0,
      productName: product['name'] ?? '',
      unitPrice: double.tryParse('${json['unit_price']}') ?? 0.0,
      subtotal: double.tryParse('${json['subtotal']}') ?? 0.0,
    );
  }
}

/// طلب إرجاع (مرتجع) — يطابق CustomerReturnResource من الباك اند.
/// GET  /api/customers/returns                → قائمة
/// GET  /api/customers/returns/{id}           → تفاصيل
/// POST /api/customers/orders/{order}/returns → إنشاء
/// POST /api/customers/returns/{id}/cancel    → إلغاء
class ReturnModel {
  final int id;
  final String
  status; // pending | picked_by_driver | return_to_warehouse | return_to_stock | damaged | rejected | approved | cancelled
  final String returnType;
  final String returnReason;
  final bool canCancel;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int orderId;
  final String orderStatus;
  final double orderTotalPrice;
  final DateTime orderDate;
  final String customerLocation;
  final String orderQrCode;
  final int warehouseId;
  final String warehouseName;

  final List<ReturnItemModel> items;

  ReturnModel({
    required this.id,
    required this.status,
    required this.returnType,
    required this.returnReason,
    required this.canCancel,
    required this.createdAt,
    required this.updatedAt,
    required this.orderId,
    required this.orderStatus,
    required this.orderTotalPrice,
    required this.orderDate,
    required this.customerLocation,
    required this.orderQrCode,
    required this.warehouseId,
    required this.warehouseName,
    this.items = const [],
  });

  /// مجموع قيمة العناصر المرتجعة (المبلغ المستحق/المسترجع).
  double get dueAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// تصنيف عرضي مبسّط يجمّع حالات الباك اند الفعلية (8 حالات) بثلاث فئات
  /// تتوافق مع تابات الواجهة:
  ///  - pending    → لسا قيد الانتظار (لسا ما تمت الموافقة)
  ///  - inProgress → تمت الموافقة وعم يترجّع فعلياً (approved/picked_by_driver/return_to_warehouse)
  ///  - archived   → انتهى المرتجع (رجع للمخزون/تالف/مرفوض/ملغى)
  ReturnUiCategory get uiCategory {
    switch (status) {
      case 'pending':
        return ReturnUiCategory.pending;
      case 'approved':
      case 'picked_by_driver':
      case 'return_to_warehouse':
        return ReturnUiCategory.inProgress;
      default:
        // return_to_stock, damaged, rejected, cancelled
        return ReturnUiCategory.archived;
    }
  }

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? {};
    final warehouse = order['warehouse'] as Map<String, dynamic>? ?? {};
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return ReturnModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      returnType: json['return_type'] ?? 'customer_return',
      returnReason: json['return_reason'] ?? '',
      canCancel: json['can_cancel'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      orderId: order['id'] ?? 0,
      orderStatus: order['status'] ?? '',
      orderTotalPrice: double.tryParse('${order['total_price']}') ?? 0.0,
      orderDate: DateTime.tryParse(order['order_date'] ?? '') ?? DateTime.now(),
      customerLocation: order['customer_location'] ?? '',
      orderQrCode: order['order_qr_code'] ?? '',
      warehouseId: warehouse['id'] ?? 0,
      warehouseName: warehouse['warehouse_name'] ?? '',
      items: itemsJson
          .map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum ReturnUiCategory { pending, inProgress, archived }
