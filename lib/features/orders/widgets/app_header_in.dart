import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/core/constants/app_text_styles.dart';
import 'package:customer_app/core/utils/nav_utils.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final BorderRadius? borderRadius;
    final double extraBottomPadding;  

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.showNotification = false,
    this.onNotificationTap,
    this.borderRadius,
       this.extraBottomPadding = 0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:  EdgeInsets.fromLTRB(20, 12, 20, 20 + extraBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row الأيقونات ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  showBack
                      ? GestureDetector(
                          onTap: () => NavUtils.safePop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  showNotification
                      ? GestureDetector(
                          onTap: onNotificationTap,
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 29),

              // ── العنوان ──────────────────────────────────────
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                 padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    title,
                    style: AppTextStyles.screenhomeTitle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}