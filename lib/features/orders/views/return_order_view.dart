import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:customer_app/features/auth/models/order_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../controllers/returns_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

/// شاشة تقديم طلب إرجاع فعلي لطلبية حقيقية مستلمة (delivered).
/// POST /api/customers/orders/{order}/returns
class ReturnOrderView extends StatefulWidget {
  final OrderModel order;
  final String orderNumber;

  const ReturnOrderView({
    super.key,
    required this.order,
    required this.orderNumber,
  });

  @override
  State<ReturnOrderView> createState() => _ReturnOrderViewState();
}

class _ReturnOrderViewState extends State<ReturnOrderView> {
  final _controller = ReturnsController();

  // الكمية المطلوب إرجاعها لكل عنصر (order_item_id → quantity), 0 = مش مختار.
  final Map<int, int> _returnQuantities = {};
  String? _selectedReason;
  bool _isSubmitting = false;
  String? _errorMessage;

  final TextEditingController _otherReasonController = TextEditingController();

  final List<String> _reasons = [
    'Wrong item received',
    'Damaged product',
    'Not as described',
    'Changed my mind',
    'Other',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _returnQuantities.values.any((q) => q > 0) &&
      _selectedReason != null &&
      (_selectedReason != 'Other' ||
          _otherReasonController.text.trim().isNotEmpty);

  /// مجموع قيمة العناصر المختارة للإرجاع (بناءً على سعر الوحدة الحقيقي).
  double get _selectedTotal {
    double total = 0;
    for (final item in widget.order.items) {
      final qty = _returnQuantities[item.id] ?? 0;
      total += qty * item.unitPrice;
    }
    return total;
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final reason = _selectedReason == 'Other'
        ? _otherReasonController.text.trim()
        : _selectedReason!;

    final items = widget.order.items
        .where((item) => (_returnQuantities[item.id] ?? 0) > 0)
        .map(
          (item) => {
            'order_item_id': item.id,
            'quantity': _returnQuantities[item.id]!,
          },
        )
        .toList();

    final result = await _controller.submitReturn(
      orderId: widget.order.id,
      returnReason: reason,
      items: items,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      _showConfirmationDialog(result.dueAmount);
    } else {
      setState(() {
        _errorMessage =
            _controller.errorMessage ?? 'errors.return_submit_failed'.tr();
      });
    }
  }

  void _showConfirmationDialog(double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
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
            Text(
              'Return Request Submitted',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Your return request has been submitted for review. '
              'An amount of \$${amount.toStringAsFixed(2)} will be refunded '
              'to your wallet upon successful verification.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.popUntil(context, (route) => route.isFirst);
              },
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
              child: const Text(
                'Done',
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

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
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
                          'Warehouse #${widget.order.warehouseId}',
                          style: AppTextStyles.fieldLabel.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Select the quantity and items you wish to return. Please provide a reason for the return.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text('ITEMS IN ORDER', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSizes.md),

                  if (widget.order.items.isEmpty)
                    Text(
                      'orders.no_items_in_order'.tr(),
                      style: AppTextStyles.bodySmall,
                    )
                  else
                    ...widget.order.items.map((item) {
                      final selectedQty = _returnQuantities[item.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: _buildReturnItem(
                          name: item.productName,
                          price: item.unitPrice,
                          quantity: selectedQty,
                          maxQuantity: item.quantity,
                          onDecrement: () => setState(() {
                            if (selectedQty > 0) {
                              _returnQuantities[item.id] = selectedQty - 1;
                            }
                          }),
                          onIncrement: () => setState(() {
                            if (selectedQty < item.quantity) {
                              _returnQuantities[item.id] = selectedQty + 1;
                            }
                          }),
                        ),
                      );
                    }),

                  const SizedBox(height: AppSizes.sm),
                  Text('REASON FOR RETURN', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSizes.sm),
                  _selectedReason == 'Other'
                      ? TextFormField(
                          controller: _otherReasonController,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Please specify the reason...',
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _selectedReason = null;
                                _otherReasonController.clear();
                              }),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.inputBorderRadius,
                              ),
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedReason,
                          hint: const Text('Select a reason...'),
                          onChanged: (v) => setState(() => _selectedReason = v),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.inputBorderRadius,
                              ),
                            ),
                          ),
                          items: _reasons
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                  if (_selectedTotal > 0) ...[
                    const SizedBox(height: AppSizes.lg),
                    Container(
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
                            'Estimated refund',
                            style: AppTextStyles.fieldLabel.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${_selectedTotal.toStringAsFixed(2)}',
                            style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSizes.md),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton(
                    onPressed: (_canProceed && !_isSubmitting) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_canProceed && !_isSubmitting)
                          ? AppColors.primary
                          : AppColors.border,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.buttonBorderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Submit Return Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
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

  Widget _buildReturnItem({
    required String name,
    required double price,
    required int quantity,
    required int maxQuantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Purchased qty: $maxQuantity',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
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
                              child: Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: AppTextStyles.fieldLabel.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: quantity < maxQuantity ? onIncrement : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: quantity < maxQuantity
                                    ? null
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.fieldLabel.copyWith(
                        fontSize: 15,
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
