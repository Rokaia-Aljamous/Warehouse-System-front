import 'package:customer_app/features/orders/widgets/order_card.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'archived_detail_view.dart';

/// "My Returns → Archived" tab.
///
/// UI matches Figma screen "طلباتي الملغاة واالمستلمة":
///  - Return #77 — Received — General Warehouse — May 10, 2024 — View Details
///  - Return #06 — Cancelled — Medicine Warehouse — May 14, 2024 — Reason: Out of stock
///  - Return #09 — Cancelled — Cap Warehouse — May 12, 2024 — Reason: Out of stock
///  - Footer "You've the end of your archive"
class ArchivedReturnsScreen extends StatelessWidget {
  const ArchivedReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      children: [
        OrderCard(
          orderNumber: 'Return #77',
          warehouseName: 'General Warehouse',
          warehouseIcon: Icons.store_outlined,
          date: 'May 10, 2024',
          status: OrderStatus.Received,
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ArchivedDetailView(
                orderNumber: 'Order #77',
              ),
            ),
          ),
        ),
        OrderCard(
          orderNumber: 'Return #06',
          warehouseName: 'Medicine Warehouse',
          warehouseIcon: Icons.medical_services_outlined,
          date: 'May 14, 2024',
          status: OrderStatus.cancelled,
          cancellationReason: 'Out of stock',
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ArchivedDetailView(
                orderNumber: 'Order #06',
              ),
            ),
          ),
        ),
        OrderCard(
          orderNumber: 'Return #09',
          warehouseName: 'Cap Warehouse',
          warehouseIcon: Icons.storefront_outlined,
          date: 'May 12, 2024',
          status: OrderStatus.cancelled,
          cancellationReason: 'Out of stock',
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ArchivedDetailView(
                orderNumber: 'Order #09',
              ),
            ),
          ),
        ),
        const _EndOfArchiveIndicator(),
      ],
    );
  }
}

class _EndOfArchiveIndicator extends StatelessWidget {
  const _EndOfArchiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xl, bottom: AppSizes.xl),
      child: Column(
        children: [
          Icon(Icons.archive_outlined, size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSizes.sm),
          Text(
            "You've the end of your archive",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
