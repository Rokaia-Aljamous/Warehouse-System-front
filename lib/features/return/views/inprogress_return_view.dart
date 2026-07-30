import 'package:customer_app/features/orders/widgets/order_card.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'return_detail_view.dart';

/// "My Returns → In Progress" tab.
///
/// UI matches Figma screen "مراجعاتي قيد الشحن":
///  - 3 order cards (Order #03, Order #02, Order #04)
///  - All "Shipping" status badge
///  - All "General Warehouse"
///  - All "May 10, 2024"
///  - Footer "End of In Progress list"
class InProgressReturnsScreen extends StatelessWidget {
  const InProgressReturnsScreen({super.key});

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
          orderNumber: 'Order #03',
          warehouseName: 'General Warehouse',
          warehouseIcon: Icons.store_outlined,
          date: 'May 10, 2024',
          status: OrderStatus.shipping,
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReturnDetailView(
                returnNumber: 'Returns #03',
                orderNumber: 'Order #03',
                status: ReturnDetailStatus.inShipping,
              ),
            ),
          ),
        ),
        OrderCard(
          orderNumber: 'Order #02',
          warehouseName: 'General Warehouse',
          warehouseIcon: Icons.store_outlined,
          date: 'May 10, 2024',
          status: OrderStatus.shipping,
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReturnDetailView(
                returnNumber: 'Returns #02',
                orderNumber: 'Order #02',
                status: ReturnDetailStatus.inShipping,
              ),
            ),
          ),
        ),
        OrderCard(
          orderNumber: 'Order #04',
          warehouseName: 'General Warehouse',
          warehouseIcon: Icons.store_outlined,
          date: 'May 10, 2024',
          status: OrderStatus.shipping,
          onViewDetails: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReturnDetailView(
                returnNumber: 'Returns #04',
                orderNumber: 'Order #04',
                status: ReturnDetailStatus.inShipping,
              ),
            ),
          ),
        ),
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
          Icon(Icons.local_shipping_outlined,
              size: 40, color: AppColors.textHint),
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
