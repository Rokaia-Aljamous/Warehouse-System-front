import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

/// Archived / Received return order detail screen.
///
/// Matches Figma screen "تفاصيل طلب مرتجع مستلم":
///   AppHeader (orderNumber)
///   Order Status banner — RECEIVED (same pattern as My Orders detail screens)
///   Warehouse card — "Clothing Warehouse"
///   RETURNED ITEMS section label
///   Item cards (Classic Jeans $660.00, Leather Belt $450.00)
///   RETURN REASON section label
///   Reason card — "Size doesn't fit correctly"
///   money refund — "$1100.00"  (green text for amount)
class ArchivedDetailView extends StatelessWidget {
  final String orderNumber;

  const ArchivedDetailView({super.key, required this.orderNumber});

  // Section label style used for RETURNED ITEMS / RETURN REASON headers.
  static final TextStyle _sectionLabelStyle =
      AppTextStyles.sectionLabel.copyWith(
    fontSize: 14,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // ── Order Status banner (RECEIVED) — same Container+Row+Icon+Text
            // pattern as the My Orders detail screens. Reuses [OrderStatus]
            // and the project's status color palette.
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
                  const Icon(Icons.check_circle_outline,
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
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.lg),

                  // ── Warehouse card ─────────────────────────────────────
                  const _ArchivedWarehouseCard(),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURNED ITEMS section ─────────────────────────────
                  Text('RETURNED ITEMS', style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),

                  const _ArchivedItemCard(
                    name: 'Classic Jeans',
                    imagePath: 'assets/images/jeans.png',
                    quantity: 1,
                    price: 660.00,
                  ),
                  const _ArchivedItemCard(
                    name: 'Leather Belt',
                    imagePath: 'assets/images/belt.png',
                    quantity: 1,
                    price: 450.00,
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURN REASON section ──────────────────────────────
                  Text('RETURN REASON', style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),
                  const _ArchivedReasonCard(
                    reason: 'Size doesn\'t fit correctly',
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── money refund card ──────────────────────────────────
                  const _MoneyRefundCard(amount: 1100.00),

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

/// Warehouse name card. Cream background, navy border, 12px radius.
class _ArchivedWarehouseCard extends StatelessWidget {
  const _ArchivedWarehouseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// Single archived item card — image left, name/qty/price right.
class _ArchivedItemCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final int quantity;
  final double price;

  const _ArchivedItemCard({
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.border,
                child: const Icon(Icons.image_outlined,
                    color: AppColors.textHint, size: 28),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
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
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Quantity: $quantity',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// RETURN REASON card — white bg, 12px radius, simple text.
class _ArchivedReasonCard extends StatelessWidget {
  final String reason;
  const _ArchivedReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        reason,
        style: AppTextStyles.fieldLabel.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// "money refund" card — label left, big amount right (green text per Figma).
class _MoneyRefundCard extends StatelessWidget {
  final double amount;
  const _MoneyRefundCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.statusApprovedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.statusApprovedTxt),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'money refund',
            style: AppTextStyles.fieldLabel.copyWith(
              color: AppColors.statusApprovedTxt,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 20,
              color: AppColors.statusApprovedTxt,
            ),
          ),
        ],
      ),
    );
  }
}
