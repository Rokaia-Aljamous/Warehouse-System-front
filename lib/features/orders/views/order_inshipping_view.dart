import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:customer_app/controllers/orders_controller.dart';
import 'package:customer_app/features/auth/models/order_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_summary.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class InShippingView extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final OrderStatus status;

  const InShippingView({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.status,
  });

  @override
  State<InShippingView> createState() => _InShippingViewState();
}

class _InShippingViewState extends State<InShippingView> {
  final _controller = OrdersController();
  bool _isLoading = true;
  String? _errorMessage;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final order = await _controller.fetchOrderDetails(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
        if (order == null) _errorMessage = 'orders.details_load_failed'.tr();
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'orders.details_load_error'.tr();
      });
    }
  }

  /// Bottom sheet for "Cancel Order" — same style as the existing one,
  /// used as the visual template for all bottom sheets in this screen.
  void _showCancelDialog() {
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
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            Text(
              'Cancel Order',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              'Are you sure you want to cancel the order? Please note that shipping fees will be deducted from your balance.',
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
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Cancel order',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
              ),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet for "QR Code" — الآن عم يعرض QR حقيقي مبني على
  /// order.orderQrCode الجاي من الباك اند، بدل الأيقونة الثابتة يلي كانت مكانه.
  /// هاد هو الكود يلي السائق بيصوره عند التسليم للتأكد من مطابقة الطلبية.
  void _showQrCodeSheet() {
    final qrData = _order?.orderQrCode ?? '';

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
              'Confirm Delivery',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Please show this QR code to the delivery agent or scan the provided receipt.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.xl),

            // QR code area — QR حقيقي متولّد محلياً من order_qr_code
            Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(10),
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
              child: qrData.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 160,
                        color: AppColors.primary,
                      ),
                    )
                  : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
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

            // Confirm Receipt — opens the next bottom sheet
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close this sheet
                _showConfirmReceiptSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Receipt',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Back to order — dismisses the sheet
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
              ),
              child: Text(
                'Back to order',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet for "Confirm Receipt" — opens after the QR Code sheet's
  /// "Confirm Receipt" button is tapped. Same visual template (drag handle,
  /// white card, rounded top corners). Shows success icon + transaction
  /// details + "Confirm & Pay" button that pops back to the first route.
  void _showConfirmReceiptSheet() {
    final total = _order?.totalPrice ?? 0.0;
    const serviceFee = 12.00;

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

            // Success icon
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
            Text(widget.orderNumber, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSizes.xl),

            // Transaction details card
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
                  _buildRow('Total Amount', '\$ ${total.toStringAsFixed(2)}'),
                  const SizedBox(height: AppSizes.sm),
                  _buildRow(
                    'Service Fee',
                    '\$ ${serviceFee.toStringAsFixed(2)}',
                  ),
                  const Divider(height: AppSizes.lg),
                  _buildRow(
                    'Total to Deduct',
                    '\$ ${(total + serviceFee).toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              '* an amount will be deducted from your Wallet Balance. Make sure you have enough balance.',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),

            // Confirm & Pay — pops back to the first route
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm & Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              title: widget.orderNumber,
              showBack: true,
              showNotification: true,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              extraBottomPadding: 25,
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Text(_errorMessage!, style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadOrder,
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              )
            else ...[
              // ── Status Badge ──────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: _getBgColorForStatus(
                    widget.status,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForStatus(widget.status),
                      color: _getBgColorForStatus(widget.status),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getStatusText(widget.status),
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: _getBgColorForStatus(widget.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── اسم المستودع ────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.warehouseBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.store_outlined,
                            color: AppColors.iconColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            'Warehouse #${_order!.warehouseId}',
                            style: AppTextStyles.fieldLabel.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // ── ITEMS IN ORDER ──────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEMS IN ORDER',
                          style: AppTextStyles.sectionLabel,
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Editing is only available through the driver',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),

                    if (_order!.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'orders.no_items_in_order'.tr(),
                          style: AppTextStyles.fieldLabel,
                        ),
                      )
                    else
                      ..._order!.items.map(
                        (item) => OrderItemCard(
                          name: item.productName,
                          imagePath: 'assets/images/med1.png',
                          networkImage: item.mainImage,
                          quantity: item.quantity,
                          price: item.unitPrice,
                          isEditMode: false,
                        ),
                      ),
                    const SizedBox(height: AppSizes.lg),

                    OrderSummary(
                      subtotal: _order!.totalPrice,
                      shippingFee: 12.00,
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // ── أزرار الـ Shipping تحت بعض ────────────
                    Column(
                      children: [
                        // QR Code — كحلي مع أيقونة. يفتح Bottom Sheet مع الباركود الحقيقي.
                        ElevatedButton.icon(
                          onPressed: _showQrCodeSheet,
                          icon: const Icon(
                            Icons.qr_code_2,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonBorderRadius,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),

                        // Cancel Order — أحمر outline
                        OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 52),
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel order',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBgColorForStatus(OrderStatus status) {
    switch (status) {
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

  IconData _getIconForStatus(OrderStatus status) {
    switch (status) {
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
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
