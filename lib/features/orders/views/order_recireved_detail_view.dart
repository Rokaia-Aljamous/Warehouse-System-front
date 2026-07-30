
import 'package:customer_app/features/orders/views/return_order_view.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_summary.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class ReceivedOrderDetailView extends StatelessWidget {
  final String orderNumber;

  const ReceivedOrderDetailView({
    super.key,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              title: orderNumber,
              showBack: true,
              showNotification: true,
              onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              extraBottomPadding: 25,
            ),

            // ── Status Badge ──────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.statusApprovedTxt.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppColors.statusApprovedTxt, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'RECEIVED',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: AppColors.statusApprovedTxt,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── اسم المستودع ────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            color: AppColors.iconColor, size: 20),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Clothing Warehouse',
                          style: AppTextStyles.fieldLabel.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // ── ITEMS IN ORDER — بدون تعديل ──────────
                  Text('ITEMS IN ORDER', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSizes.md),

                  OrderItemCard(
                    name: 'Classic Jeans',
                    imagePath: 'assets/images/jeans.png',
                    quantity: 1,
                    price: 680.00,
                    isEditMode: false,
                  ),
                  OrderItemCard(
                    name: 'Leather Belt',
                    imagePath: 'assets/images/belt.png',
                    quantity: 1,
                    price: 450.00,
                    isEditMode: false,
                  ),
                  const SizedBox(height: AppSizes.lg),

                  OrderSummary(subtotal: 1130.00, shippingFee: 12.00),
                  const SizedBox(height: AppSizes.lg),

                  // ── Return available until ────────────────
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Return available until Oct 27, 2023 (3 days remaining)',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ── زر Return Order ──────────────────────
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReturnOrderView(
                          orderNumber: orderNumber,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.replay_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: const Text(
                      'Return Order',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}