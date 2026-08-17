import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

class OrderItemCard extends StatelessWidget {
  final String name;
  final String imagePath; // asset محلي (يُستخدم كـ fallback)
  final String? networkImage; // رابط صورة حقيقي من الباكيند (اختياري)
  final int quantity;
  final double price;
  final VoidCallback? onDelete;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool isEditMode; // أضفنا هذا المتغير

  const OrderItemCard({
    super.key,
    required this.name,
    required this.imagePath,
    this.networkImage,
    required this.quantity,
    required this.price,
    this.onDelete,
    this.onIncrement,
    this.onDecrement,
    this.isEditMode = false, // القيمة الافتراضية false
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان بناءً على وضع التعديل
    final Color iconDeleteColor = isEditMode ? Colors.red : AppColors.textHint;
    final Color actionIconColor = isEditMode
        ? AppColors.primary
        : AppColors.textHint;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── صورة المنتج ───────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (networkImage != null && networkImage!.isNotEmpty)
                ? Image.network(
                    networkImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.border,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.border,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSizes.md),

          // ── الاسم + quantity + سعر ────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // أيقونة الحذف تظهر وتتغير باللون الأحمر في وضع التعديل
                    GestureDetector(
                      onTap: isEditMode ? onDelete : null,
                      child: Icon(
                        Icons.delete_outline,
                        color: isEditMode
                            ? Colors.red
                            : Colors.transparent, // تظهر فقط في وضع التعديل
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── +/- (تتغير الألوان بناءً على isEditMode) ──
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isEditMode
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onDecrement,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: isEditMode
                                    ? Colors.red
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: AppTextStyles.fieldLabel.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: onIncrement,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: actionIconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── السعر ─────────────────────────────────
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        color: AppColors.textPrimary,
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
