import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class ReturnOrderView extends StatefulWidget {
  final String orderNumber;

  const ReturnOrderView({super.key, required this.orderNumber});

  @override
  State<ReturnOrderView> createState() => _ReturnOrderViewState();
}

class _ReturnOrderViewState extends State<ReturnOrderView> {
  int _jeansQty = 0;
  int _beltQty = 0;
  String? _selectedReason;
  
  // إضافة الـ Controller
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  // تحديث شرط التحقق ليدعم حالة الـ Other
  bool get _canProceed =>
      (_jeansQty > 0 || _beltQty > 0) &&
      (_selectedReason != null && 
      (_selectedReason != 'Other' || _otherReasonController.text.trim().isNotEmpty));

  final List<String> _reasons = [
    'Wrong item received',
    'Damaged product',
    'Not as described',
    'Changed my mind',
    'Other',
  ];

  void _showRefundDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.pagePaddingH, AppSizes.xl, AppSizes.pagePaddingH, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppSizes.lg),
            Text('Refund Confirmation', style: AppTextStyles.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: AppSizes.sm),
            Text('Your return request is being processed. An amount of \$1100.00 will be refunded to your wallet upon successful verification.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSizes.lg),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)),
                elevation: 0,
              ),
              child: const Text('Confirm and Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Not now', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
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
            AppHeader(title: widget.orderNumber, showBack: true, showNotification: true, onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)), extraBottomPadding: 25),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(color: AppColors.statusApprovedTxt.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.statusApprovedTxt, size: 24),
                  const SizedBox(width: 12),
                  Text('RECEIVED', style: AppTextStyles.fieldLabel.copyWith(color: AppColors.statusApprovedTxt, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
                    child: Row(children: [const Icon(Icons.store_outlined, color: AppColors.iconColor, size: 20), const SizedBox(width: AppSizes.sm), Text('Clothing Warehouse', style: AppTextStyles.fieldLabel.copyWith(fontSize: 16, color: AppColors.textPrimary))]),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text('Select the quantity and items you wish to return. Please provide a reason for the return.', style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppSizes.lg),
                  Text('ITEMS IN ORDER', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSizes.md),
                  _buildReturnItem(name: 'Classic Jeans', imagePath: 'assets/images/jeans.png', price: 660.00, quantity: _jeansQty, onDecrement: () => setState(() => _jeansQty > 0 ? _jeansQty-- : null), onIncrement: () => setState(() => _jeansQty++)),
                  const SizedBox(height: AppSizes.md),
                  _buildReturnItem(name: 'Leather Belt', imagePath: 'assets/images/belt.png', price: 450.00, quantity: _beltQty, onDecrement: () => setState(() => _beltQty > 0 ? _beltQty-- : null), onIncrement: () => setState(() => _beltQty++)),
                  const SizedBox(height: AppSizes.lg),

                  // تم دمج التبديل هنا:
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
                            suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _selectedReason = null; _otherReasonController.clear(); })),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius)),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedReason,
                          hint: const Text('Select a reason...'),
                          onChanged: (v) => setState(() => _selectedReason = v),
                          decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius))),
                          items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: AppTextStyles.bodySmall))).toList(),
                        ),
                  
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton(
                    onPressed: _canProceed ? _showRefundDialog : null,
                    style: ElevatedButton.styleFrom(backgroundColor: _canProceed ? AppColors.primary : AppColors.border, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)), elevation: 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Show docs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const SizedBox(width: AppSizes.sm), const Icon(Icons.arrow_forward, color: Colors.white, size: 18)]),
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

  Widget _buildReturnItem({required String name, required String imagePath, required double price, required int quantity, required VoidCallback onDecrement, required VoidCallback onIncrement}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.border, child: const Icon(Icons.image_outlined, color: AppColors.textHint)))),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.fieldLabel.copyWith(fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [GestureDetector(onTap: onDecrement, child: const Padding(padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs), child: Icon(Icons.remove, size: 16))), Text('$quantity', style: AppTextStyles.fieldLabel.copyWith(fontSize: 14)), GestureDetector(onTap: onIncrement, child: const Padding(padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs), child: Icon(Icons.add, size: 16)))]),
                    ),
                    Text('\$${price.toStringAsFixed(2)}', style: AppTextStyles.fieldLabel.copyWith(fontSize: 15, color: AppColors.textPrimary)),
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