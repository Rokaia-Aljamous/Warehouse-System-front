import 'package:customer_app/controllers/notification_controller.dart';
import 'package:customer_app/features/notifications/models/notification_model.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';

/// شاشة "إشعاراتي" — بعد التعديل صارت مربوطة فعلياً بـ NotificationController
/// (بدل البيانات الوهمية الثابتة). القسمين "جديد"/"سابقاً" هلق مبنيين على
/// isRead الحقيقي القادم من /api/customers/notifications.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _controller = NotificationController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    // أول ما تُفتح الشاشة منجدد القائمة (اشتراك التوكن أصلاً صار بـ HomeView).
    _controller.refresh();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onNotificationTap(CustomerNotification notification) async {
    await _controller.markAsRead(notification);
  }

  @override
  Widget build(BuildContext context) {
    final newItems = _controller.unreadNotifications;
    final earlierItems = _controller.readNotifications;
    final isLoading =
        _controller.isLoading && _controller.notifications.isEmpty;
    final hasError =
        _controller.error != null && _controller.notifications.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      bottomNavigationBar: buildAppBottomNav(context, 0),
      body: Column(
        children: [
          AppHeader(
            title: 'notifications.title'.tr(),
            showBack: true,
            showNotification: false, // we ARE on the notifications screen
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
            extraBottomPadding: 25,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refresh,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePaddingH,
                        AppSizes.lg,
                        AppSizes.pagePaddingH,
                        AppSizes.xl,
                      ),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            'errors.unexpected'.tr(),
                            style: AppTextStyles.fieldLabel,
                          ),
                        ),
                      ],
                    )
                  : newItems.isEmpty && earlierItems.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePaddingH,
                        AppSizes.lg,
                        AppSizes.pagePaddingH,
                        AppSizes.xl,
                      ),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            'notifications.empty'.tr(),
                            style: AppTextStyles.fieldLabel,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePaddingH,
                        AppSizes.lg,
                        AppSizes.pagePaddingH,
                        AppSizes.xl,
                      ),
                      children: [
                        if (newItems.isNotEmpty) ...[
                          _SectionLabel(text: 'notifications.new_label'.tr()),
                          const SizedBox(height: AppSizes.sm),
                          ...newItems.map(
                            (item) => _NotificationRow(
                              item: item,
                              onTap: () => _onNotificationTap(item),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        if (earlierItems.isNotEmpty) ...[
                          _SectionLabel(
                            text: 'notifications.earlier_label'.tr(),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          ...earlierItems.map(
                            (item) => _NotificationRow(
                              item: item,
                              onTap: () => _onNotificationTap(item),
                            ),
                          ),
                        ],
                      ],
                    ),
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
  final CustomerNotification item;
  final VoidCallback onTap;
  const _NotificationRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  color: isUnread
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
                    item.displayText,
                    style: AppTextStyles.fieldLabel.copyWith(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      color: isUnread
                          ? AppColors.textPrimary
                          : const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.relativeTime,
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
      ),
    );
  }
}
