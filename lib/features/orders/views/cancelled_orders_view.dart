import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/models/order_model.dart';
import '../widgets/order_card.dart';

class CancelledOrdersScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const CancelledOrdersScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Text('orders.no_cancelled_orders'.tr()));
    }
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePaddingH),
      children: orders.map((order) {
        final date =
            '${order.orderDate.year}-${order.orderDate.month.toString().padLeft(2, '0')}-${order.orderDate.day.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: OrderCard(
            orderNumber: 'Order #${order.id}',
            warehouseName: 'Warehouse #${order.warehouseId}',
            warehouseIcon: Icons.warehouse_outlined,
            date: date,
            status: OrderStatus.cancelled,
            cancellationReason: order.status == 'rejected'
                ? 'Rejected by warehouse'
                : null,
            onViewDetails: () {},
          ),
        );
      }).toList(),
    );
  }
}
