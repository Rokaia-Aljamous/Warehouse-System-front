import 'package:customer_app/features/orders/views/return_order_view.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_barcode_widget.dart';
import 'package:customer_app/controllers/orders_controller.dart';
import 'package:customer_app/features/auth/models/order_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/order_item_card.dart';
import '../widgets/order_summary.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

/// تفاصيل طلبية مستلمة (delivered) — يجيب بيانات حقيقية عبر [orderId]
/// (بنفس نمط OrderDetailView المستخدم لبقية حالات الطلبية).
class ReceivedOrderDetailView extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const ReceivedOrderDetailView({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<ReceivedOrderDetailView> createState() =>
      _ReceivedOrderDetailViewState();
}

class _ReceivedOrderDetailViewState extends State<ReceivedOrderDetailView> {
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
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
        if (order == null) _errorMessage = 'orders.details_load_failed'.tr();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'orders.details_load_error'.tr();
      });
    }
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
            else if (_errorMessage != null || _order == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  _errorMessage ?? 'common.error_generic'.tr(),
                  style: AppTextStyles.fieldLabel,
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
                  color: AppColors.statusApprovedTxt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.statusApprovedTxt,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'RECEIVED',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: AppColors.statusApprovedTxt,
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
                    // ── اسم المستودع (حقيقي) ────────────────────────
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

                    // ── ITEMS IN ORDER (حقيقية) ──────────────
                    Text('ITEMS IN ORDER', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: AppSizes.md),

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
                      shippingFee: 0.00,
                    ),

                    OrderBarcodeWidget(orderQrCode: _order!.orderQrCode),
                    const SizedBox(height: AppSizes.md),

                    // ── زر Return Order (حقيقي) ──────────────────────
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReturnOrderView(
                            order: _order!,
                            orderNumber: widget.orderNumber,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.replay_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      label: const Text(
                        'Return Order',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.buttonBorderRadius,
                          ),
                        ),
                      ),
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
}
