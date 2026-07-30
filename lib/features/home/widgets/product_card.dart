import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/home/views/product_details_view.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image; // مسار asset محلي (يُستخدم كـ fallback)
  final String? networkImage; // رابط صورة حقيقي من الباكيند (اختياري)
  final VoidCallback? onAddToCart; // لو موجودة، بيصير الزر "Add to cart"
  final bool isAdding;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    this.networkImage,
    this.onAddToCart,
    this.isAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFocused, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: (networkImage != null && networkImage!.isNotEmpty)
                  ? Image.network(
                      networkImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: isAdding
                            ? null
                            : () {
                                if (onAddToCart != null) {
                                  onAddToCart!();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ProductDetailsView(),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isAdding
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                onAddToCart != null ? 'Add to cart' : 'See more',
                                style: const TextStyle(fontSize: 10),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
