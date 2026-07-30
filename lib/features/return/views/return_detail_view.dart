import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/views/home_view.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

/// Status variant for [ReturnDetailView].
/// Drives which action button is shown.
enum ReturnDetailStatus { pending, inShipping }

/// Return order detail screen.
///
/// Matches Figma screens:
///  - "تفاصيل طلب مرتجع قيد الانتظار"  → status = [ReturnDetailStatus.pending]
///  - "تفاصيل طلب مرتجع قيد الشحن"     → status = [ReturnDetailStatus.inShipping]
///
/// Layout (top → bottom):
///   AppHeader (orderNumber or returnNumber)
///   Order Status banner (same widget pattern as My Orders detail screens)
///   Warehouse card — "Clothing Warehouse"
///   RETURNED ITEMS section label
///   Item cards (Classic Jeans $660.00, Leather Belt $450.00)
///   RETURN REASON section label
///   Reason card — "Size doesn't fit correctly"
///   Your due money — "$1100.00"
///   Action button —
///       pending     → "Cancel Return Request" (outlined red, opens bottom sheet)
///       inShipping  → "QR Code" (filled navy, opens bottom sheet — not a new page)
class ReturnDetailView extends StatelessWidget {
  final String returnNumber;
  final String orderNumber;
  final ReturnDetailStatus status;

  const ReturnDetailView({
    super.key,
    required this.returnNumber,
    required this.orderNumber,
    this.status = ReturnDetailStatus.inShipping,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = status == ReturnDetailStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: isPending ? orderNumber : returnNumber,
              showBack: true,
              showNotification: true,
              onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              extraBottomPadding: 25,
            ),

            // ── Order Status banner (same style as My Orders detail screens)
            // Reuses the same Container+Row+Icon+Text pattern as
            // order_pending_view / order_inshipping_view / order_recireved_detail_view.
            _OrderStatusBanner(status: status),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.lg),

                  // ── Warehouse card ─────────────────────────────────────
                  const _WarehouseCard(),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURNED ITEMS section ─────────────────────────────
                  Text('RETURNED ITEMS', style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),

                  const _ReturnItemCard(
                    name: 'Classic Jeans',
                    imagePath: 'assets/images/jeans.png',
                    quantity: 1,
                    price: 660.00,
                  ),
                  const _ReturnItemCard(
                    name: 'Leather Belt',
                    imagePath: 'assets/images/belt.png',
                    quantity: 1,
                    price: 450.00,
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURN REASON section ──────────────────────────────
                  Text('RETURN REASON', style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),
                  const _ReturnReasonCard(
                    reason: 'Size doesn\'t fit correctly',
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── Your due money ─────────────────────────────────────
                  const _DueMoneyCard(amount: 1100.00),

                  const SizedBox(height: AppSizes.lg),

                  // ── Action button ──────────────────────────────────────
                  if (isPending)
                    OutlinedButton(
                      onPressed: () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.buttonBorderRadius),
                        ),
                      ),
                      child: const Text(
                        'Cancel Return Request',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _showQrCodeSheet(context),
                      icon: const Icon(Icons.qr_code_2,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'QR Code',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.buttonBorderRadius),
                        ),
                        elevation: 0,
                      ),
                    ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section label style used for RETURNED ITEMS / RETURN REASON headers.
  // Figma: 14px, w600, dark gray, 0.5 letter-spacing.
  static final TextStyle _sectionLabelStyle =
      AppTextStyles.sectionLabel.copyWith(
    fontSize: 14,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  /// QR Code bottom sheet — opens (instead of navigating to a new page)
  /// when the user taps the QR Code button. Same visual template as the
  /// Cancel Order bottom sheet (drag handle, white card, rounded top
  /// corners, icon header, primary action button, secondary text button).
  void _showQrCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
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
              'Return Request',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Please show this barcode to the store representative to process your return',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
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
                child: Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Confirm Return — opens the next bottom sheet (Refund Confirmation)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close this sheet
                _showRefundConfirmSheet(context);
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
              child: const Text(
                'Confirm Return',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Not now — dismisses the sheet
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
              child: const Text(
                'Not now',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Refund Confirmation bottom sheet — opens after the QR Code sheet's
  /// "Confirm Return" button is tapped. Same visual template (drag handle,
  /// white card, rounded top corners). Shows success icon + confirmation
  /// message + "Confirm and Continue" button that returns the user to Home.
  void _showRefundConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
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
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Your return request has been processed successfully. '
              'An amount of \$1100.00 has been refunded to your wallet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
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

            // Confirm and Continue — push HomeView and clear the stack
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeView()),
                  (route) => false,
                );
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
              child: const Text(
                'Confirm and Continue',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Not now — dismisses the sheet
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
              child: const Text(
                'Not now',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH, AppSizes.xl, AppSizes.pagePaddingH, 40),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Cancel Return Request',
                style: AppTextStyles.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Are you sure you want to cancel this return request?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.xl),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.buttonBorderRadius),
                ),
              ),
              child: const Text('Cancel Return Request',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.buttonBorderRadius),
                ),
              ),
              child: const Text('Go Back',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Status banner — uses the same Container + Row + Icon + Text pattern
/// as the My Orders detail screens (order_pending_view, order_inshipping_view,
/// order_recireved_detail_view). Reuses [OrderStatus] enum and the project's
/// status color palette defined in [AppColors].
class _OrderStatusBanner extends StatelessWidget {
  final ReturnDetailStatus status;

  const _OrderStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final OrderStatus orderStatus = status == ReturnDetailStatus.pending
        ? OrderStatus.pending
        : OrderStatus.shipping;

    final Color color = _bgColorForStatus(orderStatus);
    final IconData icon = _iconForStatus(orderStatus);
    final String label = _labelForStatus(orderStatus);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.fieldLabel.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Color _bgColorForStatus(OrderStatus s) {
    switch (s) {
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

  IconData _iconForStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.shipping:
        return Icons.local_shipping;
      case OrderStatus.pending:
        return Icons.autorenew;
      case OrderStatus.approved:
        return Icons.check_circle_outline;
      case OrderStatus.Received:
        return Icons.inventory;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _labelForStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.shipping:
        return 'SHIPPING';
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.approved:
        return 'APPROVED';
      case OrderStatus.Received:
        return 'RECEIVED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Warehouse name card. Cream background, navy border, 12px radius.
class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_outlined,
              color: AppColors.iconColor, size: 20),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Clothing Warehouse',
            style: AppTextStyles.fieldLabel.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single returned item card — image left, name/qty/price right.
/// Matches Figma item card spec (white bg, 12px radius, "Quantity: N" text,
/// price aligned right).
class _ReturnItemCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final int quantity;
  final double price;

  const _ReturnItemCard({
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image — 64x64 with 8px rounded corners.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.border,
                child: const Icon(Icons.image_outlined,
                    color: AppColors.textHint, size: 28),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Name + Quantity + Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Quantity: $quantity',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// RETURN REASON card — white bg, 12px radius, simple text.
class _ReturnReasonCard extends StatelessWidget {
  final String reason;
  const _ReturnReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        reason,
        style: AppTextStyles.fieldLabel.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// "Your due money" card — label left, big amount right.
class _DueMoneyCard extends StatelessWidget {
  final double amount;
  const _DueMoneyCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your due money',
            style: AppTextStyles.fieldLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
