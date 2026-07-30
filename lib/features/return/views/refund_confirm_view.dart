import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bottom-sheet dialog shown after the user confirms the return.
///
/// Uses the SAME visual template as the Cancel Order bottom sheet
/// (drag handle, white card, rounded top corners, icon header, primary
/// action button, secondary text button). NOT a full-screen page and
/// NOT a centered Dialog.
///
/// Show with: showModalBottomSheet(context: ctx, builder: (_) => RefundConfirmView(...));
///
/// The parent screen owns the navigation. [onConfirmAndContinue] is
/// invoked AFTER this sheet is dismissed, so the parent can safely
/// navigate (e.g. back to Home) using its own still-mounted context.
class RefundConfirmView extends StatelessWidget {
  final String orderNumber;
  final String amount;

  /// Called when the user taps "Confirm and Continue".
  /// The sheet will be dismissed first; this callback is then invoked
  /// via [Future.microtask] so the parent can navigate safely.
  final VoidCallback? onConfirmAndContinue;

  const RefundConfirmView({
    super.key,
    required this.orderNumber,
    this.amount = '\$1100.00',
    this.onConfirmAndContinue,
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
            'Refund Confirmation',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Your return request has been processed successfully. '
            'An amount of $amount has been refunded to your wallet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Success icon (green circle with check)
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.statusApprovedBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.statusApprovedTxt,
              size: 60,
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Primary: Confirm and Continue
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final cb = onConfirmAndContinue;
              if (cb != null) {
                Future.microtask(cb);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSizes.buttonBorderRadius),
              ),
              elevation: 0,
            ),
            child: const Text('Confirm and Continue',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
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
                borderRadius:
                    BorderRadius.circular(AppSizes.buttonBorderRadius),
              ),
            ),
            child: const Text('Not now',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
