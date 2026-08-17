import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio = DioClient.instance;

  /// كاش بسيط بالذاكرة (بيفضى مع كل إعادة تشغيل للتطبيق) — يمنع تكرار
  /// نفس طلب الصورة لنفس productId أكتر من مرة بالجلسة الواحدة. مشترك
  /// بين كل نسخ ProductRepository لأنه static.
  static final Map<int, String?> _imageCache = {};

  Future<List<ProductModel>> getProducts({
    required String token,
    required int warehouseId,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/products',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List data = response.data['products'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  /// GET /api/customers/warehouses/{warehouse}/products/{product}
  /// بيرجّع بيانات منتج واحد كاملة (تستخدم بشاشة تفاصيل المنتج).
  Future<ProductModel> getProduct({
    required String token,
    required int warehouseId,
    required int productId,
  }) async {
    final response = await _dio.get(
      '/api/customers/warehouses/$warehouseId/products/$productId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ProductModel.fromJson(response.data['product']);
  }

  /// بترجع رابط صورة منتج واحد بس (مش الكائن كامل)، معتمدة على الكاش
  /// أول شي. تستخدم لتعبئة صور عناصر السلة/الطلبات، بما إنه الباك اند
  /// ما بيرجّع main_image ضمن ردود السلة/الطلبات نفسها — فبنجيبها من
  /// endpoint المنتج الفردي يلي أصلاً بيرجّعها صح.
  ///
  /// لو صار أي خطأ (مثلاً المنتج انحذف)، بترجع null بهدوء بدون ما توقف
  /// عرض بقية الشاشة.
  Future<String?> getProductImage({
    required String token,
    required int warehouseId,
    required int productId,
  }) async {
    if (_imageCache.containsKey(productId)) {
      return _imageCache[productId];
    }
    try {
      final product = await getProduct(
        token: token,
        warehouseId: warehouseId,
        productId: productId,
      );
      _imageCache[productId] = product.mainImage;
      return product.mainImage;
    } catch (_) {
      return null;
    }
  }
}
