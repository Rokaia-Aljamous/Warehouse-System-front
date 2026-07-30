import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

/// "Notifications" screen — matches Figma design "اشعاراتي".
///
/// Layout:
///   AppHeader(title: 'Notification', showBack, showNotification)
///   "New" section label
///     - Destruction task assigned: Order #1234 ... 2m ago (unread, green dot)
///     - New receiving task: Shipment from Supplier X ... 15m ago (unread)
///   "Earlier" section label
///     - Storage task: Move 50 units of Product A to Zone B. 2h ago (read, gray dot)
///     - Inventory check required for Section 4. 5h ago (read)
///     - System alert: Inventory levels low for Item #5521. Yesterday (read)
///
/// Items use no card borders — just spacing and an unread-dot on the left.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  // "New" section items (unread — green dot, white background).
  static const List<_NotificationItem> _newItems = [
    _NotificationItem(
      title: 'Destruction task assigned: Order #1234 requires processing.',
      time: '2m ago',
      isUnread: true,
    ),
    _NotificationItem(
      title:
          'New receiving task: Shipment from Supplier X has arrived.',
      time: '15m ago',
      isUnread: true,
    ),
  ];

  // "Earlier" section items (read — gray dot).
  static const List<_NotificationItem> _earlierItems = [
    _NotificationItem(
      title: 'Storage task: Move 50 units of Product A to Zone B.',
      time: '2h ago',
      isUnread: false,
    ),
    _NotificationItem(
      title: 'Inventory check required for Section 4.',
      time: '5h ago',
      isUnread: false,
    ),
    _NotificationItem(
      title: 'System alert: Inventory levels low for Item #5521.',
      time: 'Yesterday',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          AppHeader(
            title: 'Notification',
            showBack: true,
            showNotification: false, // we ARE on the notifications screen
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
            extraBottomPadding: 25,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.lg,
                AppSizes.pagePaddingH,
                AppSizes.xl,
              ),
              children: [
                _SectionLabel(text: 'New'),
                const SizedBox(height: AppSizes.sm),
                ..._newItems.map((item) => _NotificationRow(item: item)),
                const SizedBox(height: AppSizes.lg),
                _SectionLabel(text: 'Earlier'),
                const SizedBox(height: AppSizes.sm),
                ..._earlierItems.map((item) => _NotificationRow(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Uppercase section label (e.g. "New", "Earlier") — small, medium weight.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.fieldLabel.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4B5563),
        letterSpacing: 1.0,
      ),
    );
  }
}

/// A single notification row: unread/read dot + title + timestamp.
class _NotificationRow extends StatelessWidget {
  final _NotificationItem item;
  const _NotificationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread (green) / Read (gray) indicator dot
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.isUnread
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title + timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontSize: 15,
                    fontWeight: item.isUnread
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: item.isUnread
                        ? AppColors.textPrimary
                        : const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple notification item value holder.
class _NotificationItem {
  final String title;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.title,
    required this.time,
    required this.isUnread,
  });
}
