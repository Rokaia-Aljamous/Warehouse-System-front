import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../views/warehouse_details_view.dart';

class WarehouseCard extends StatelessWidget {
  final int warehouseId;
  final String title;
  final String location;
  final String warehouseType;
  final double? area;
  final double? financialBudgets;

  const WarehouseCard({
    super.key,
    required this.warehouseId,
    required this.title,
    required this.location,
    required this.warehouseType,
    this.area,
    this.financialBudgets,
  });

  @override
  Widget build(BuildContext context) {
    const cardBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(72),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: cardBorderRadius,
        border: Border.all(color: AppColors.borderFocused, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // ← تم التصحيح
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: cardBorderRadius,
        child: InkWell(
          borderRadius: cardBorderRadius,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WarehouseDetailsView(
                  warehouseId: warehouseId,
                  title: title,
                  location: location,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.iconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(location, style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.warehouse_outlined,
                      size: 16,
                      color: AppColors.iconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(warehouseType, style: AppTextStyles.bodySmall),
                  ],
                ),
                if (area != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.square_foot_outlined,
                        size: 16,
                        color: AppColors.iconColor,
                      ),
                      const SizedBox(width: 4),
                      Text('${area!.toStringAsFixed(0)} m²',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
                if (financialBudgets != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money_outlined,
                        size: 16,
                        color: AppColors.iconColor,
                      ),
                      const SizedBox(width: 4),
                      Text(financialBudgets!.toStringAsFixed(0),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}