import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/core/constants/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum OrderStatus { shipping, pending, approved, cancelled, Received }

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(),
        style: AppTextStyles.fieldLabel.copyWith(
          color: _textColor(),
          fontSize: 11,
        ),
      ),
    );
  }

  String _label() {
    switch (status) {
      case OrderStatus.shipping:
        return 'status.shipping'.tr();
      case OrderStatus.pending:
        return 'status.pending'.tr();
      case OrderStatus.approved:
        return 'status.approved'.tr();
      case OrderStatus.cancelled:
        return 'status.cancelled'.tr();
      case OrderStatus.Received:
        return 'status.received'.tr();
    }
  }

  Color _bgColor() {
    switch (status) {
      case OrderStatus.shipping:
        return AppColors.statusShippingBg;
      case OrderStatus.pending:
        return AppColors.statusPendingBg;
      case OrderStatus.approved:
      case OrderStatus.Received:
        return AppColors.statusApprovedBg; // تم دمجهم لتقليل التكرار
      case OrderStatus.cancelled:
        return AppColors.statusCancelledBg;
    }
  }

  Color _textColor() {
    switch (status) {
      case OrderStatus.shipping:
        return AppColors.statusShippingTxt;
      case OrderStatus.pending:
        return AppColors.statusPendingTxt;
      case OrderStatus.approved:
      case OrderStatus.Received:
        return AppColors.statusApprovedTxt;
      case OrderStatus.cancelled:
        return AppColors.statusCancelledTxt;
    }
  }
}
