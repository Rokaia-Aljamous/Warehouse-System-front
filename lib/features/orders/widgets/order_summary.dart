import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.shippingFee,
  });

  double get total => subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusApprovedTxt, width: 1),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', subtotal, isBold: false),
          const SizedBox(height: AppSizes.sm),
          _buildRow('Shipping Fee', shippingFee, isBold: false),
          const Divider(height: AppSizes.lg),
          _buildRow('Total Amount', total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.bodySmall,
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isBold
              ? AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                )
              : AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}