import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String warehouseName;
  final IconData warehouseIcon;
  final String date;
  final OrderStatus status;
  final VoidCallback onViewDetails;
  final String? cancellationReason;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.warehouseName,
    required this.warehouseIcon,
    required this.date,
    required this.status,
    required this.onViewDetails,
    this.cancellationReason,
  });

  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(72),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: _radius,
        border: Border.all(color: AppColors.borderFocused, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          onTap: onViewDetails,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderNumber,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                    ),
                    OrderStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(warehouseIcon, size: 16, color: AppColors.iconColor),
                    const SizedBox(width: 4),
                    Text(warehouseName, style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                if (cancellationReason != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(
                        alpha: 0.05,
                      ), // لون خلفية خفيف
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'orders.reason_label'.tr(args: [cancellationReason!]),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: AppTextStyles.bodySmall),
                    Row(
                      children: [
                        Text(
                          'common.view_details'.tr(),
                          style: AppTextStyles.fieldLabel.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
