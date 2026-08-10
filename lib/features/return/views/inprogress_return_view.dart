import 'package:customer_app/features/orders/widgets/order_card.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/return_model.dart';
import 'return_detail_view.dart';

/// "My Returns → In Progress" tab. مرتبط الآن بمرتجعات حقيقية من الباك اند
/// (الحالات: approved / picked_by_driver / return_to_warehouse).
class InProgressReturnsScreen extends StatelessWidget {
  final List<ReturnModel> returns;

  const InProgressReturnsScreen({super.key, required this.returns});

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
        children: const [_EndOfInProgressListIndicator()],
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
          return OrderCard(
            orderNumber: 'Return #${item.id}',
            warehouseName: item.warehouseName.isNotEmpty
                ? item.warehouseName
                : 'Warehouse #${item.warehouseId}',
            warehouseIcon: Icons.store_outlined,
            date: date,
            status: OrderStatus.shipping,
            onViewDetails: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReturnDetailView(returnId: item.id),
              ),
            ),
          );
        }),
        const _EndOfInProgressListIndicator(),
      ],
    );
  }
}

class _EndOfInProgressListIndicator extends StatelessWidget {
  const _EndOfInProgressListIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xl, bottom: AppSizes.xl),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 40,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'End of In Progress list',
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
