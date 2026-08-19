import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_barcode_widget.dart';
import 'package:customer_app/features/auth/widgets/app_button.dart';
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
import 'package:customer_app/features/orders/views/transaction_details_view.dart';

class OrderApprovedView extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderApprovedView({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderApprovedView> createState() => _OrderApprovedViewState();
}

class _OrderApprovedViewState extends State<OrderApprovedView> {
  final _controller = OrdersController();
  bool isEditMode = false; // للتحكم بظهور أزرار Edit و Cancel
  bool isSendingMode = false; // للتحكم بظهور زر Send Order
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
                    AppButton(
                      label: 'common.retry'.tr(),
                      onPressed: _loadOrder,
                    ),
                  ],
                ),
              )
            else ...[
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Text(
                      "APPROVED",
                      style: TextStyle(
                        color: Colors.green,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.warehouseBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEMS IN ORDER',
                          style: AppTextStyles.sectionLabel,
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            isEditMode = !isEditMode;
                            isSendingMode =
                                false; // إعادة ضبط الحالة عند إغلاق التعديل
                          }),
                          icon: Icon(
                            isEditMode ? Icons.close : Icons.edit_outlined,
                            color: isEditMode
                                ? Colors.red
                                : AppColors.textSecondary,
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
                          isEditMode: isEditMode,
                        ),
                      ),

                    const SizedBox(height: AppSizes.lg),
                    OrderSummary(
                      subtotal: _order!.totalPrice,
                      shippingFee: 0.00,
                    ),

                    // ── الباركود الخاص بالطلبية ──────────────────
                    OrderBarcodeWidget(orderQrCode: _order!.orderQrCode),

                    // ── زر الدفع عبر PayPal (يفتح شاشة تأكيد الدفع) ──
                    // بيظهر فقط لما can_pay == true (مو بس status ==
                    // approved) — can_pay هو المرجع الوحيد من الباك اند
                    // لمعرفة إذا مسموح تبلّشي دفع جديد لهاد الطلب.
                    if (!isEditMode && _order!.canPay) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'orders.pay_now'.tr(),
                        fullWidth: true,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsView(
                                orderId: _order!.id,
                                orderNumber: widget.orderNumber,
                                totalPrice: _order!.totalPrice,
                              ),
                            ),
                          );
                          // بعد الرجوع من شاشة الدفع (نجاح أو إلغاء)
                          // نعيد تحميل الطلب حتى يتحدث can_pay/payment_status.
                          if (mounted) _loadOrder();
                        },
                        color: AppColors.primary,
                        textColor: AppColors.textOnPrimary,
                      ),
                    ] else if (!isEditMode && _order!.isPaid) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'orders.payment_success'.tr(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── منطق الأزرار ───────────────────────────
                    if (isEditMode) ...[
                      const SizedBox(height: 20),
                      isSendingMode
                          ? AppButton(
                              label: "Send Order",
                              fullWidth: true,
                              onPressed: () => setState(() {
                                isEditMode = false;
                                isSendingMode = false;
                              }),
                              color: AppColors.primary,
                              textColor: AppColors.textOnPrimary,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: "Cancel",
                                    onPressed: () =>
                                        setState(() => isEditMode = false),
                                    borderColor: Colors.red,
                                    color: Colors.white,
                                    textColor: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppButton(
                                    label: "Edit",
                                    onPressed: () =>
                                        setState(() => isSendingMode = true),
                                    color: AppColors.primary,
                                    textColor: AppColors.textOnPrimary,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 30),
                    ],
                    const SizedBox(height: 20),
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
