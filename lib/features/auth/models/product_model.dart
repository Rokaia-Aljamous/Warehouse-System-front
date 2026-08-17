import '../../../core/network/api_constants.dart';

/// يمثل منتج داخل مستودع معيّن.
/// GET /api/customers/warehouses/{warehouse}/products
class ProductModel {
  final int id;
  final String name;
  final String? brand;
  final String? type;
  final String? mainImage;
  final double sellingPrice;

  ProductModel({
    required this.id,
    required this.name,
    this.brand,
    this.type,
    this.mainImage,
    required this.sellingPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      type: json['type'],
      mainImage: ApiConstants.resolveImageUrl(json['main_image']),
      sellingPrice: double.tryParse('${json['selling_price']}') ?? 0.0,
    );
  }
}
