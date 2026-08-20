import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../controllers/product_details_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';

class ProductDetailsView extends StatefulWidget {
  final int warehouseId;
  final int productId;

  const ProductDetailsView({
    super.key,
    required this.warehouseId,
    required this.productId,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late final ProductDetailsController _controller;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailsController(
      warehouseId: widget.warehouseId,
      productId: widget.productId,
    );
    _controller.loadProduct();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onAddToCart() async {
    final ok = await _controller.addToCart(quantity: quantity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'home.add_to_cart_success'.tr()
              : (_controller.cartError ?? 'errors.add_to_cart_failed'.tr()),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // حالة التحميل
    if (_controller.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: buildAppBottomNav(context, 0),
      );
    }

    // حالة الخطأ
    if (_controller.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        bottomNavigationBar: buildAppBottomNav(context, 0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.errorMessage!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _controller.loadProduct,
                child: Text('common.try_again'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final product = _controller.product!;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      bottomNavigationBar: buildAppBottomNav(context, 0),
      body: Column(
        children: [
          // 1. القسم العلوي
          SizedBox(
            height: 350,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 275,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textOnPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child:
                            (product.mainImage != null &&
                                product.mainImage!.isNotEmpty)
                            ? Image.network(
                                product.mainImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  "assets/image/Glazed Donuts.png",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                "assets/image/Glazed Donuts.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. تفاصيل المنتج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnCard,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderFocused,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 18,
                              color: AppColors.cardFixedAccent,
                            ),
                            onPressed: () => setState(
                              () => quantity > 1 ? quantity-- : null,
                            ),
                          ),
                          Text(
                            "$quantity",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardFixedAccent,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.cardFixedAccent,
                            ),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // البراند والنوع صاروا كل وحدة بسطر لحالها مع أيقونة تعبّر
                // عنها (طلب منفصل عن موضوع الألوان).
                if (product.brand != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: AppColors.textOnCard,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.brand!,
                          style: AppTextStyles.productDescription.copyWith(
                            color: AppColors.textOnCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (product.type != null)
                  Row(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 18,
                        color: AppColors.textOnCard,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.type!,
                        style: AppTextStyles.productDescription.copyWith(
                          color: AppColors.textOnCard,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const Spacer(),
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$ ${product.sellingPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardFixedAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _controller.isAddingToCart ? null : _onAddToCart,
                    child: _controller.isAddingToCart
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnFixedAccent,
                            ),
                          )
                        : Text(
                            'orders.order_now'.tr(),
                            style: TextStyle(
                              color: AppColors.textOnFixedAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
