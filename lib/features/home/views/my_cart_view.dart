import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'notifications_view.dart';

/// "My Cart" screen — matches Figma design "سلتي الحالية" (My Basket).
///
/// Layout:
///   AppHeader(title: 'My Basket', showBack, showNotification)
///   ITEMS IN ORDER section label
///   Cart item cards (image left, name + qty stepper + price right, delete icon)
///   Calculate Total price button (navy, full-width)
///
/// On Calculate → opens [ConfirmOrderSheet] bottom sheet showing the invoice
/// (subtotal, shipping fee, total) + Confirm Order button → success SnackBar.
class MyCartView extends StatefulWidget {
  final int warehouseId;

  const MyCartView({super.key, required this.warehouseId});

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  late final CartController _controller;

  // القائمة المعروضة محليًا (بتتبنى من _controller.cart بعد كل تحميل/تعديل).
  List<_CartItem> _items = [];

  @override
  void initState() {
    super.initState();
    _controller = CartController(warehouseId: widget.warehouseId);
    _controller.addListener(_syncItemsFromController);
    _controller.loadCart();
  }

  @override
  void dispose() {
    _controller.removeListener(_syncItemsFromController);
    _controller.dispose();
    super.dispose();
  }

  void _syncItemsFromController() {
    final cart = _controller.cart;
    setState(() {
      _items = cart == null
          ? []
          : cart.items
                .map(
                  (e) => _CartItem(
                    cartItemId: e.id,
                    name: e.productName,
                    imagePath: 'assets/image/Glazed Donuts.png',
                    networkImage: e.mainImage,
                    quantity: e.quantity,
                    price: e.unitPrice,
                  ),
                )
                .toList();
    });
  }

  // لا يوجد رسوم شحن ثابتة من الباكيند حاليًا، فبنعتمد على المجموع الحقيقي بس.
  static const double _shippingFee = 0.0;

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  double get _total => _subtotal + _shippingFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          AppHeader(
            title: 'My Basket',
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
          Expanded(
            child: _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _controller.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _controller.errorMessage!,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        OutlinedButton(
                          onPressed: _controller.loadCart,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                : _items.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePaddingH,
                      AppSizes.lg,
                      AppSizes.pagePaddingH,
                      AppSizes.lg,
                    ),
                    children: [
                      Text('ITEMS IN ORDER', style: _sectionLabelStyle),
                      const SizedBox(height: AppSizes.md),
                      ..._items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: _CartItemCard(
                            item: item,
                            onIncrement: () => _controller.updateQuantity(
                              item.cartItemId,
                              item.quantity + 1,
                            ),
                            onDecrement: () => _controller.updateQuantity(
                              item.cartItemId,
                              item.quantity - 1,
                            ),
                            onDelete: () =>
                                _controller.removeItem(item.cartItemId),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // ── Bottom: Calculate Total price button ───────────────────
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                0,
                AppSizes.pagePaddingH,
                24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _showConfirmOrderSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.buttonBorderRadius,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Calculate Total price',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Your cart is empty',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showConfirmOrderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmOrderSheet(
        items: _items,
        subtotal: _subtotal,
        shippingFee: _shippingFee,
        total: _total,
        onConfirm: (customerLocation) async {
          final ok = await _controller.placeOrder(customerLocation);
          if (!mounted) return;
          Navigator.pop(context); // close sheet
          if (ok) {
            _showSuccessSnackBar();
          } else {
            _showErrorSnackBar(
              _controller.orderError ?? 'errors.order_failed'.tr(),
            );
          }
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          0,
          AppSizes.pagePaddingH,
          24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        ),
      ),
    );
  }

  void _showSuccessSnackBar() {
    final snackBar = SnackBar(
      content: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.white, size: 20),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Your order has been sent successfully!',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.statusApprovedTxt,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        0,
        AppSizes.pagePaddingH,
        24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static final TextStyle _sectionLabelStyle = AppTextStyles.sectionLabel
      .copyWith(
        fontSize: 14,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );
}

/// A single cart item row: image | name + qty stepper + price | delete icon.
class _CartItemCard extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Product image (60x60) — matches existing OrderItemCard size
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (item.networkImage != null && item.networkImage!.isNotEmpty)
                ? Image.network(
                    item.networkImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      item.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.border,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textHint,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    item.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.border,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                        size: 24,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSizes.md),
          // Name + qty stepper + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Delete icon — soft red
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF6B6B),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Qty stepper — reuses style from OrderItemCard
                    _QtyStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quantity stepper (− N +) — same visual language as the existing
/// `OrderItemCard` widget in /features/orders/widgets/.
class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              child: Icon(Icons.remove, size: 16, color: AppColors.textHint),
            ),
          ),
          Text(
            '$quantity',
            style: AppTextStyles.fieldLabel.copyWith(fontSize: 14),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              child: Icon(Icons.add, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with the invoice (subtotal / shipping / total) + Confirm Order.
/// Matches Figma design "تاكيد الطلب" (Order Confirm).
class _ConfirmOrderSheet extends StatefulWidget {
  final List<_CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final ValueChanged<String> onConfirm; // بيرجع عنوان التوصيل

  const _ConfirmOrderSheet({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.onConfirm,
  });

  @override
  State<_ConfirmOrderSheet> createState() => _ConfirmOrderSheetState();
}

class _ConfirmOrderSheetState extends State<_ConfirmOrderSheet> {
  final _locationController = TextEditingController();
  String? _locationError;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      setState(() => _locationError = 'cart.delivery_address_required'.tr());
      return;
    }
    widget.onConfirm(location);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.lg,
        AppSizes.pagePaddingH,
        32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Basket',
                  style: AppTextStyles.screenTitle.copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Order #88',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Section label
            Text('ITEMS IN ORDER', style: _sectionLabelStyle),
            const SizedBox(height: AppSizes.md),

            // Items list
            ...widget.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          (item.networkImage != null &&
                              item.networkImage!.isNotEmpty)
                          ? Image.network(
                              item.networkImage!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                item.imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: AppColors.border,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 16,
                                  ),
                                ),
                              ),
                            )
                          : Image.asset(
                              item.imagePath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: AppColors.border,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 16,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.fieldLabel.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: AppSizes.xl),

            // Invoice Details section
            Text('Invoice Details', style: _sectionLabelStyle),
            const SizedBox(height: AppSizes.md),
            _InvoiceRow(label: 'Subtotal', value: widget.subtotal),
            const SizedBox(height: AppSizes.sm),
            _InvoiceRow(label: 'Shipping Fee', value: widget.shippingFee),
            const SizedBox(height: AppSizes.md),
            // Total amount card
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: AppTextStyles.screenTitle.copyWith(
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // حقل عنوان التوصيل — مطلوب من الباكيند (customer_location)
            TextField(
              controller: _locationController,
              onChanged: (_) {
                if (_locationError != null) {
                  setState(() => _locationError = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Delivery address',
                hintText: 'cart.delivery_address_hint'.tr(),
                errorText: _locationError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Confirm Order button (navy, full-width)
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.buttonBorderRadius,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Confirm Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Back to Order Details — text button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Order Details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final TextStyle _sectionLabelStyle = AppTextStyles.sectionLabel
      .copyWith(
        fontSize: 12,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final double value;
  const _InvoiceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 14)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: AppTextStyles.fieldLabel.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Simple cart item value holder.
class _CartItem {
  final int cartItemId; // رقم صف السلة الحقيقي بقاعدة البيانات
  final String name;
  final String imagePath; // asset محلي احتياطي (fallback)
  final String? networkImage; // رابط الصورة الحقيقي من الباك اند
  int quantity;
  final double price;

  _CartItem({
    required this.cartItemId,
    required this.name,
    required this.imagePath,
    this.networkImage,
    required this.quantity,
    required this.price,
  });
}
