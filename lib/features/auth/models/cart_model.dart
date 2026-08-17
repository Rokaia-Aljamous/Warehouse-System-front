import '../../../core/network/api_constants.dart';

/// عنصر داخل السلة (منتج + كمية).
class CartItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? mainImage;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.mainImage,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse('${json['unit_price']}') ?? 0.0,
      subtotal: double.tryParse('${json['subtotal']}') ?? 0.0,
      mainImage: ApiConstants.resolveImageUrl(json['main_image']),
    );
  }

  /// بيرجع نسخة جديدة من نفس العنصر لكن بصورة مختلفة — تستخدم لتعبئة
  /// الصورة محليًا (frontend enrichment) لما الباك اند ما يرجعها ضمن
  /// رد السلة نفسه.
  CartItemModel copyWith({String? mainImage}) {
    return CartItemModel(
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

/// السلة الكاملة الخاصة بمستودع معيّن.
/// GET /api/customers/warehouses/{warehouse}/cart
class CartModel {
  final int id;
  final int warehouseId;
  final List<CartItemModel> items;
  final double totalPrice;
  final int itemsCount;

  CartModel({
    required this.id,
    required this.warehouseId,
    required this.items,
    required this.totalPrice,
    required this.itemsCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse_id'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: double.tryParse('${json['total_price']}') ?? 0.0,
      itemsCount: json['items_count'] ?? 0,
    );
  }

  /// سلة فاضية (تستخدم لما الباكيند يرجع cart: null، يعني ما في سلة بعد).
  factory CartModel.empty(int warehouseId) => CartModel(
    id: 0,
    warehouseId: warehouseId,
    items: [],
    totalPrice: 0,
    itemsCount: 0,
  );

  /// بيرجع نسخة جديدة من نفس السلة لكن بقائمة items مختلفة — تستخدم
  /// بعد تعبئة صور المنتجات محليًا.
  CartModel copyWithItems(List<CartItemModel> items) {
    return CartModel(
      id: id,
      warehouseId: warehouseId,
      items: items,
      totalPrice: totalPrice,
      itemsCount: itemsCount,
    );
  }
}
