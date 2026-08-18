import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/orders/widgets/order_status_badge.dart';
import 'package:customer_app/features/orders/widgets/order_barcode_widget.dart';
import 'package:customer_app/features/auth/widgets/app_button.dart';
import 'package:customer_app/controllers/orders_controller.dart';
import 'package:customer_app/features/auth/models/order_model.dart';
import 'package:customer_app/features/auth/models/product_model.dart';
import 'package:customer_app/features/auth/repositories/product_repository.dart';
import 'package:customer_app/core/storage/token_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../widgets/order_item_card.dart';
import '../widgets/order_summary.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final OrderStatus status;

  const OrderDetailView({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.status,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final _controller = OrdersController();
  final _productRepository = ProductRepository();
  bool isEditMode = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  OrderModel? _order;

  // ── حالة وضع التعديل (محلية، لغاية ما يتم الحفظ فعلياً) ──────────
  // الكمية الحالية لكل منتج (product_id → quantity)
  final Map<int, int> _draftQuantities = {};
  // المنتجات يلي انحذفت بوضع التعديل (product_id) لكن لسا ما انحفظت
  final Set<int> _draftRemovedIds = {};

  // ── منتجات جديدة مضافة بوضع التعديل (مش أصلاً بالطلبية) ──────────
  // product_id → quantity
  final Map<int, int> _draftNewItems = {};
  // بيانات المنتج (اسم/سعر/صورة) للمنتجات الجديدة، لعرضها قبل الحفظ
  final Map<int, ProductModel> _draftNewProducts = {};

  /// هل مسموح تعديل هاد الطلب أصلاً؟ (الباك اند برضو بيرفض لو مش pending،
  /// بس منمنع الزر من الأساس بالفرونت لتجربة استخدام أوضح).
  bool get _canEditOrder => widget.status == OrderStatus.pending;

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

  /// يفعّل وضع التعديل ويجهّز نسخة عمل (draft) من الكميات الحالية.
  void _enterEditMode() {
    _draftQuantities.clear();
    _draftRemovedIds.clear();
    if (_order != null) {
      for (final item in _order!.items) {
        _draftQuantities[item.productId] = item.quantity;
      }
    }
    setState(() => isEditMode = true);
  }

  /// يلغي أي تعديلات مسودة ويرجع لوضع العرض العادي بدون ما يرسل شي للسيرفر.
  void _cancelEdit() {
    setState(() {
      isEditMode = false;
      _draftQuantities.clear();
      _draftRemovedIds.clear();
      _draftNewItems.clear();
      _draftNewProducts.clear();
    });
  }

  void _incrementDraft(int productId) {
    setState(() {
      _draftQuantities[productId] = (_draftQuantities[productId] ?? 1) + 1;
    });
  }

  void _decrementDraft(int productId) {
    setState(() {
      final current = _draftQuantities[productId] ?? 1;
      if (current > 1) _draftQuantities[productId] = current - 1;
    });
  }

  void _removeDraft(int productId) {
    setState(() => _draftRemovedIds.add(productId));
  }

  // ── منتجات جديدة (Add product) ──────────────────────────────────

  void _incrementNewDraft(int productId) {
    setState(() {
      _draftNewItems[productId] = (_draftNewItems[productId] ?? 1) + 1;
    });
  }

  void _decrementNewDraft(int productId) {
    setState(() {
      final current = _draftNewItems[productId] ?? 1;
      if (current > 1) {
        _draftNewItems[productId] = current - 1;
      }
    });
  }

  void _removeNewDraft(int productId) {
    setState(() {
      _draftNewItems.remove(productId);
      _draftNewProducts.remove(productId);
    });
  }

  /// يفتح شاشة سفلية (bottom sheet) فيها منتجات مستودع الطلبية، ما عدا
  /// اللي أصلاً موجودة بالطلبية (وما انحذفت) أو انضافت مسبقاً بهاد
  /// الجلسة، وبيضيف أي منتج يتم اختياره لقائمة "_draftNewItems".
  Future<void> _openAddProductSheet() async {
    if (_order == null) return;

    final token = await TokenStorage.getToken();
    if (token == null) return;

    List<ProductModel> allProducts = [];
    bool isLoadingProducts = true;
    String? loadError;

    try {
      allProducts = await _productRepository.getProducts(
        token: token,
        warehouseId: _order!.warehouseId,
      );
      isLoadingProducts = false;
    } catch (_) {
      isLoadingProducts = false;
      loadError = 'orders.details_load_failed'.tr();
    }

    if (!mounted) return;

    final existingIds = _order!.items
        .where((item) => !_draftRemovedIds.contains(item.productId))
        .map((item) => item.productId)
        .toSet();

    final selectable = allProducts
        .where(
          (p) =>
              !existingIds.contains(p.id) && !_draftNewItems.containsKey(p.id),
        )
        .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              20,
              AppSizes.pagePaddingH,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'orders.add_product_title'.tr(),
                  style: AppTextStyles.sectionLabel.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (isLoadingProducts)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (loadError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(loadError, style: AppTextStyles.fieldLabel),
                  )
                else if (selectable.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'orders.no_more_products_to_add'.tr(),
                      style: AppTextStyles.fieldLabel,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: selectable.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = selectable[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                (product.mainImage != null &&
                                    product.mainImage!.isNotEmpty)
                                ? Image.network(
                                    product.mainImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 48,
                                      height: 48,
                                      color: AppColors.border,
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.border,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: AppTextStyles.fieldLabel.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '\$${product.sellingPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _draftNewItems[product.id] = 1;
                                _draftNewProducts[product.id] = product;
                              });
                              Navigator.pop(sheetContext);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// يرسل التعديلات الفعلية للباك اند: PATCH /api/customers/orders/{id}
  Future<void> _saveEdit() async {
    if (_order == null) return;

    final existingItems = _order!.items
        .where((item) => !_draftRemovedIds.contains(item.productId))
        .map(
          (item) => {
            'product_id': item.productId,
            'quantity': _draftQuantities[item.productId] ?? item.quantity,
          },
        )
        .toList();

    final newItems = _draftNewItems.entries
        .map((entry) => {'product_id': entry.key, 'quantity': entry.value})
        .toList();

    final items = [...existingItems, ...newItems];

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('orders.min_one_item_required'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = await _controller.updateOrderItems(
      orderId: widget.orderId,
      items: items,
    );

    setState(() => _isSaving = false);

    if (updated != null) {
      setState(() {
        _order = updated;
        isEditMode = false;
        _draftQuantities.clear();
        _draftRemovedIds.clear();
        _draftNewItems.clear();
        _draftNewProducts.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('orders.update_success'.tr())));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('orders.update_failed'.tr())));
      }
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
              // ── شريط حالة الطلب ──────────────────────────────
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
                  color: _getBgColorForStatus(widget.status).withOpacity(0.15),
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

              // ── المحتوى الرئيسي ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المستودع (الآن من بيانات الطلبية الحقيقية)
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

                    // عنوان القائمة + زر التعديل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEMS IN ORDER',
                          style: AppTextStyles.sectionLabel,
                        ),
                        // زر التعديل بيظهر فقط لو الطلب لسا "قيد الانتظار".
                        // بعد ما توافق الإدارة عليه (أو أي حالة تانية) ما
                        // في داعي نظهره أصلاً — الباك اند برضو بيرفض
                        // التعديل بهاي الحالة، بس هيك التجربة أوضح للمستخدم.
                        if (_canEditOrder)
                          IconButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    if (isEditMode) {
                                      _cancelEdit();
                                    } else {
                                      _enterEditMode();
                                    }
                                  },
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

                    // قائمة المنتجات الحقيقية الجاية من الباك اند
                    if (_order!.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'orders.no_items_in_order'.tr(),
                          style: AppTextStyles.fieldLabel,
                        ),
                      )
                    else
                      ..._order!.items
                          .where(
                            (item) =>
                                !(isEditMode &&
                                    _draftRemovedIds.contains(item.productId)),
                          )
                          .map(
                            (item) => OrderItemCard(
                              name: item.productName,
                              imagePath: 'assets/images/med1.png',
                              networkImage: item.mainImage,
                              quantity: isEditMode
                                  ? (_draftQuantities[item.productId] ??
                                        item.quantity)
                                  : item.quantity,
                              price: item.unitPrice,
                              isEditMode: isEditMode,
                              onIncrement: isEditMode
                                  ? () => _incrementDraft(item.productId)
                                  : null,
                              onDecrement: isEditMode
                                  ? () => _decrementDraft(item.productId)
                                  : null,
                              onDelete: isEditMode
                                  ? () => _removeDraft(item.productId)
                                  : null,
                            ),
                          ),

                    // ── المنتجات الجديدة المضافة بوضع التعديل (لسا ما انحفظت) ──
                    if (isEditMode && _draftNewItems.isNotEmpty)
                      ..._draftNewItems.entries.map((entry) {
                        final product = _draftNewProducts[entry.key];
                        if (product == null) return const SizedBox.shrink();
                        return OrderItemCard(
                          name: product.name,
                          imagePath: 'assets/images/med1.png',
                          networkImage: product.mainImage,
                          quantity: entry.value,
                          price: product.sellingPrice,
                          isEditMode: true,
                          onIncrement: () => _incrementNewDraft(product.id),
                          onDecrement: () => _decrementNewDraft(product.id),
                          onDelete: () => _removeNewDraft(product.id),
                        );
                      }),

                    // ── زر إضافة منتج جديد (يظهر فقط بوضع التعديل) ──
                    if (isEditMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _openAddProductSheet,
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          label: Text('orders.add_product'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSizes.lg),
                    OrderSummary(
                      subtotal: _order!.totalPrice,
                      shippingFee: 0.00, // لسا مافي حقل رسوم شحن منفصل بالـ API
                    ),

                    // ── الباركود الخاص بالطلبية ──────────────────
                    // ── الباركود ─────────────────────────────────
                    // ما بيظهر إلا بعد ما يتوافق على الطلب (approved
                    // أو أي حالة بعدها زي shipping/Received). طالما
                    // الطلب لسا "قيد الانتظار" ما في داعي للباركود.
                    if (widget.status != OrderStatus.pending)
                      OrderBarcodeWidget(orderQrCode: _order!.orderQrCode),

                    // ── أزرار التعديل (تظهر فقط في وضع التعديل) ──
                    if (isEditMode) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: "Cancel",
                              onPressed: _isSaving ? null : _cancelEdit,
                              borderColor: Colors.red,
                              color: Colors.white,
                              textColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: _isSaving ? "..." : "Save",
                              onPressed: _isSaving ? null : _saveEdit,
                              color: AppColors.primary,
                              textColor: Colors.white,
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

  // الدوال المساعدة للـ Status
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
