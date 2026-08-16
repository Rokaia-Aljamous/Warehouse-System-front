import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bottom-sheet dialog shown when the user taps "QR Code" on the
/// in-shipping return detail screen.
///
/// Uses the SAME visual template as the Cancel Order bottom sheet
/// (drag handle, white card, rounded top corners, icon header, primary
/// action button, secondary text button). NOT a full-screen page and
/// NOT a centered Dialog.
///
/// Show with: showModalBottomSheet(context: ctx, builder: (_) => ReturnProcessView(...));
///
/// The parent screen owns the dialog flow. [onConfirmReturn] is invoked
/// AFTER this sheet is dismissed, so the parent can safely show the next
/// sheet (RefundConfirmView) using its own still-mounted context.
class ReturnProcessView extends StatelessWidget {
  final String returnNumber;
  final String orderNumber;

  /// Called when the user taps "Confirm Return".
  /// The sheet will be dismissed first; this callback is then invoked
  /// via [Future.microtask] so the parent can show the next sheet.
  final VoidCallback? onConfirmReturn;

  const ReturnProcessView({
    super.key,
    required this.returnNumber,
    required this.orderNumber,
    this.onConfirmReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.xl,
        AppSizes.pagePaddingH,
        40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Title + description
          Text(
            'returns.return_request_title'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'returns.show_barcode_to_staff'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: AppSizes.xl),

          // QR code area (200x200)
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
              child: Icon(Icons.qr_code_2, size: 160, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Primary: Confirm Return
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final cb = onConfirmReturn;
              if (cb != null) {
                Future.microtask(cb);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.buttonBorderRadius,
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              'returns.confirm_return'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Secondary: Not now
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.buttonBorderRadius,
                ),
              ),
            ),
            child: Text(
              'common.not_now'.tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
