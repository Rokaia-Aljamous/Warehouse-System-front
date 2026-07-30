
import 'package:customer_app/features/auth/widgets/app_button.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class TransactionDetailsView extends StatelessWidget {
  final String orderNumber;

  const TransactionDetailsView({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          AppHeader(
            title: orderNumber,
            showBack: true,
            showNotification: true,
            onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
            extraBottomPadding: 25,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.xl),

                  // ── أيقونة نجاح ─────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  Text(
                    'Scan Successful',
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSizes.xs),

                  Text(
                    orderNumber,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ── Transaction Details ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style: AppTextStyles.fieldLabel.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        _buildRow('Total Amount', '\$ 1000.00'),
                        const SizedBox(height: AppSizes.sm),
                        _buildRow('Service Fee', '\$ 12.00'),
                        const Divider(height: AppSizes.lg),
                        _buildRow(
                          'Total to Deduct',
                          '\$ 1012.00',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // ── ملاحظة ──────────────────────────────────
                  Text(
                    '* an amount will be deducted from your Wallet Balance. Make sure you have enough balance.',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ── زر Confirm & Pay ─────────────────────────
                  AppButton(
                    label: 'Confirm & Pay',
                    fullWidth: true,
                    onPressed: () {
                      // TODO: API call للدفع
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    color: AppColors.primary,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.bodySmall,
        ),
        Text(
          value,
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