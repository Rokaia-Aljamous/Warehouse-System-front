import 'package:customer_app/features/orders/widgets/order_card.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/return_model.dart';
import 'archived_detail_view.dart';

/// "My Returns → Archived" tab. مرتبط الآن بمرتجعات حقيقية من الباك اند
/// (الحالات النهائية: return_to_stock / damaged / rejected / cancelled).
class ArchivedReturnsScreen extends StatelessWidget {
  final List<ReturnModel> returns;

  const ArchivedReturnsScreen({super.key, required this.returns});

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.md,
          AppSizes.pagePaddingH,
          AppSizes.xl,
        ),
        children: const [_EndOfArchiveIndicator()],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      children: [
        ...returns.map((item) {
          final date =
              '${item.updatedAt.year}-${item.updatedAt.month.toString().padLeft(2, '0')}-${item.updatedAt.day.toString().padLeft(2, '0')}';
          final isCancelledOrRejected =
              item.status == 'cancelled' || item.status == 'rejected';

          return OrderCard(
            orderNumber: 'Return #${item.id}',
            warehouseName: item.warehouseName.isNotEmpty
                ? item.warehouseName
                : 'Warehouse #${item.warehouseId}',
            warehouseIcon: Icons.store_outlined,
            date: date,
            status: isCancelledOrRejected
                ? OrderStatus.cancelled
                : OrderStatus.Received,
            cancellationReason: isCancelledOrRejected
                ? item.returnReason
                : null,
            onViewDetails: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArchivedDetailView(returnId: item.id),
              ),
            ),
          );
        }),
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
