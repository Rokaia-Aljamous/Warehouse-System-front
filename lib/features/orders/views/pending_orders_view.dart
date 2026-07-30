import 'package:customer_app/features/orders/views/order_approved_view.dart';
import 'package:customer_app/features/orders/views/order_inshipping_view.dart';
import 'package:customer_app/features/orders/views/order_pending_view.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/models/order_model.dart';
import '../widgets/order_card.dart';

class PendingOrdersScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const PendingOrdersScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبيات قيد الانتظار'));
    }
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePaddingH),
      children: orders.map((order) {
        final orderNumber = 'Order #${order.id}';
        final date =
            '${order.orderDate.year}-${order.orderDate.month.toString().padLeft(2, '0')}-${order.orderDate.day.toString().padLeft(2, '0')}';
        final localStatus = order.status == 'approved'
            ? OrderStatus.approved
            : OrderStatus.pending;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: OrderCard(
            orderNumber: orderNumber,
            warehouseName: 'Warehouse #${order.warehouseId}',
            warehouseIcon: Icons.warehouse_outlined,
            date: date,
            status: localStatus,
            onViewDetails: () {
              if (localStatus == OrderStatus.approved) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderApprovedView(
                      orderId: order.id,
                      orderNumber: orderNumber,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailView(
                      orderId: order.id,
                      orderNumber: orderNumber,
                      status: localStatus,
                    ),
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
