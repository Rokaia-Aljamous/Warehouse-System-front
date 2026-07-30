
import 'package:customer_app/features/auth/widgets/app_button.dart';
import 'package:customer_app/features/orders/views/transaction_details_view.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';


class ConfirmDeliveryView extends StatelessWidget {
  final String orderNumber;

  const ConfirmDeliveryView({super.key, required this.orderNumber});

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

                  // ── عنوان ──────────────────────────────────
                  Text(
                    'Confirm Delivery',
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  Text(
                    'Please show this QR code to the delivery agent or scan the provided receipt.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ── QR Code ─────────────────────────────────
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 160,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  Text(
                    'Scan me',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ── زر Confirm Receipt ──────────────────────
                  AppButton(
                    label: 'Confirm Receipt',
                    fullWidth: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailsView(
                          orderNumber: orderNumber,
                        ),
                      ),
                    ),
                    color: AppColors.primary,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ── Back to order ───────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Back to order',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}