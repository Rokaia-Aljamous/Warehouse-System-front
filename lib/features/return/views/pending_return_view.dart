import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/return_model.dart';
import 'return_detail_view.dart';

/// "My Returns → Pending" tab. مرتبط الآن بمرتجعات حقيقية من الباك اند.
class PendingReturnsScreen extends StatelessWidget {
  final List<ReturnModel> returns;

  const PendingReturnsScreen({super.key, required this.returns});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      itemCount: returns.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == returns.length) {
          return _EndOfListIndicator(text: 'returns.end_of_pending'.tr());
        }
        final item = returns[index];
        return _PendingReturnCard(
          data: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReturnDetailView(returnId: item.id),
            ),
          ),
        );
      },
    );
  }
}

/// Single pending return card.
class _PendingReturnCard extends StatelessWidget {
  final ReturnModel data;
  final VoidCallback onTap;

  const _PendingReturnCard({required this.data, required this.onTap});

  // Same asymmetric radius used by the shared OrderCard widget so the
  // visual style stays consistent across all list screens.
  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(72),
  );

  @override
  Widget build(BuildContext context) {
    final date =
        '${data.createdAt.year}-${data.createdAt.month.toString().padLeft(2, '0')}-${data.createdAt.day.toString().padLeft(2, '0')}';

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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Return number + "Under Review" badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'returns.return_number'.tr(args: [data.id.toString()]),
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                    ),
                    const _UnderReviewBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                // Warehouse name with icon
                Row(
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 16,
                      color: AppColors.iconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.warehouseName.isNotEmpty
                          ? data.warehouseName
                          : 'orders.warehouse_number'.tr(
                              args: [data.warehouseId.toString()],
                            ),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Date + View Details link
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
                        const Icon(
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

/// "Under Review" pill badge — matches Figma styling.
/// Uses the pending palette already defined in [AppColors].
class _UnderReviewBadge extends StatelessWidget {
  const _UnderReviewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusPendingBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'returns.under_review'.tr(),
        style: AppTextStyles.fieldLabel.copyWith(
          color: AppColors.statusPendingTxt,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// End-of-list footer (clipboard icon + gray text).
class _EndOfListIndicator extends StatelessWidget {
  final String text;
  const _EndOfListIndicator({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xl, bottom: AppSizes.xl),
      child: Column(
        children: [
          Icon(Icons.history_outlined, size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSizes.sm),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
