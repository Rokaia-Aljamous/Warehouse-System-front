import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'return_detail_view.dart';

/// "My Returns → Pending" tab.
///
/// UI matches Figma screen "مرتجعاتي قيد الانتظار":
///  - 3 return cards (Return #03, #04, #02)
///  - All "Under Review" status badge (red)
///  - All "Medicine Warehouse"
///  - All "May 14, 2024"
///  - Footer "End of pending list"
///
/// The existing `OrderCard` widget only supports fixed labels ("Pending",
/// "Shipping", ...) so we build the list item inline to match the Figma
/// "Under Review" badge text exactly. Card shape (asymmetric bottom-right
/// corner) and spacing match the rest of the app.
class PendingReturnsScreen extends StatelessWidget {
  const PendingReturnsScreen({super.key});

  static const List<_PendingReturnData> _items = [
    _PendingReturnData(returnNumber: 'Return #03', orderNumber: 'Order #03'),
    _PendingReturnData(returnNumber: 'Return #04', orderNumber: 'Order #04'),
    _PendingReturnData(returnNumber: 'Return #02', orderNumber: 'Order #02'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      itemCount: _items.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const _EndOfListIndicator(text: 'End of pending list');
        }
        final item = _items[index];
        return _PendingReturnCard(
          data: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReturnDetailView(
                returnNumber: item.returnNumber,
                orderNumber: item.orderNumber,
                status: ReturnDetailStatus.pending,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Single pending return card.
class _PendingReturnCard extends StatelessWidget {
  final _PendingReturnData data;
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
                      data.returnNumber,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                    ),
                    const _UnderReviewBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                // Warehouse name with icon
                Row(
                  children: [
                    const Icon(Icons.store_outlined,
                        size: 16, color: AppColors.iconColor),
                    const SizedBox(width: 4),
                    Text('Medicine Warehouse',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                // Date + View Details link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('May 14, 2024', style: AppTextStyles.bodySmall),
                    Row(
                      children: [
                        Text(
                          'View Details',
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
        'Under Review',
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
          Icon(Icons.history_outlined,
              size: 40, color: AppColors.textHint),
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

/// Simple value holder for a pending return row.
class _PendingReturnData {
  final String returnNumber;
  final String orderNumber;
  const _PendingReturnData({
    required this.returnNumber,
    required this.orderNumber,
  });
}
