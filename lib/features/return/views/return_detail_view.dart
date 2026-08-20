import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../controllers/returns_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/views/home_view.dart';
import '../models/return_model.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';
import '../../home/widgets/app_bottom_nav.dart';

/// Return order detail screen — يجيب المرتجع الحقيقي حسب [returnId] من الباك اند.
///
/// Layout (top → bottom):
///   AppHeader (Return #id)
///   Order Status banner
///   Warehouse card
///   RETURNED ITEMS section
///   RETURN REASON section
///   Your due money
///   Action button —
///       pending      → "Cancel Return Request" (يستدعي POST /returns/{id}/cancel فعلياً)
///       غير ذلك      → "QR Code" (يعرض QR الطلبية الأصلي — إجراء معلوماتي، بدون نداء API)
class ReturnDetailView extends StatefulWidget {
  final int returnId;

  const ReturnDetailView({super.key, required this.returnId});

  @override
  State<ReturnDetailView> createState() => _ReturnDetailViewState();
}

class _ReturnDetailViewState extends State<ReturnDetailView> {
  final _controller = ReturnsController();
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _errorMessage;
  ReturnModel? _returnData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final data = await _controller.fetchReturnDetails(widget.returnId);
    if (!mounted) return;
    setState(() {
      _returnData = data;
      _isLoading = false;
      if (data == null) _errorMessage = 'returns.details_load_failed'.tr();
    });
  }

  // Section label style used for RETURNED ITEMS / RETURN REASON headers.
  static final TextStyle _sectionLabelStyle = AppTextStyles.sectionLabel
      .copyWith(
        fontSize: 14,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.cardBg,
        bottomNavigationBar: buildAppBottomNav(context, 2),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_returnData == null) {
      return Scaffold(
        backgroundColor: AppColors.cardBg,
        bottomNavigationBar: buildAppBottomNav(context, 2),
        body: Center(
          child: Text(
            _errorMessage ?? 'errors.unexpected'.tr(),
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }

    final data = _returnData!;
    final isPending = data.status == 'pending';

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      bottomNavigationBar: buildAppBottomNav(context, 2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'returns.return_number'.tr(args: [data.id.toString()]),
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

            _OrderStatusBanner(status: data.status),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.lg),

                  // ── Warehouse card ─────────────────────────────────────
                  _WarehouseCard(
                    name: data.warehouseName.isNotEmpty
                        ? data.warehouseName
                        : 'orders.warehouse_number'.tr(
                            args: [data.warehouseId.toString()],
                          ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURNED ITEMS section ─────────────────────────────
                  Text(
                    'returns.returned_items'.tr(),
                    style: _sectionLabelStyle,
                  ),
                  const SizedBox(height: AppSizes.md),

                  if (data.items.isEmpty)
                    Text(
                      'returns.no_items'.tr(),
                      style: AppTextStyles.bodySmall,
                    )
                  else
                    ...data.items.map(
                      (item) => _ReturnItemCard(
                        name: item.productName,
                        quantity: item.quantity,
                        price: item.subtotal,
                      ),
                    ),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURN REASON section ──────────────────────────────
                  Text('returns.return_reason'.tr(), style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),
                  _ReturnReasonCard(reason: data.returnReason),

                  const SizedBox(height: AppSizes.lg),

                  // ── Your due money ─────────────────────────────────────
                  _DueMoneyCard(amount: data.dueAmount),

                  const SizedBox(height: AppSizes.lg),

                  if (_errorMessage != null && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),

                  // ── Action button ──────────────────────────────────────
                  if (isPending)
                    OutlinedButton(
                      onPressed: _isCancelling
                          ? null
                          : () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.buttonBorderRadius,
                          ),
                        ),
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'returns.cancel_return_request'.tr(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )
                  else if (data.orderQrCode.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _showQrCodeSheet(context, data),
                      icon: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'returns.qr_code'.tr(),
                        style: const TextStyle(
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
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// QR Code bottom sheet — معلوماتي فقط (بيعرض رمز الطلبية الأصلي للمرتجع
  /// حتى يبينه الزبون لموظف المستودع)، بدون أي نداء API وهمي.
  void _showQrCodeSheet(BuildContext context, ReturnModel data) {
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
            Text(
              'returns.return_request_title'.tr(),
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'returns.show_qr_to_staff'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.xl),
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(12),
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
              child: Center(
                child: Text(
                  data.orderQrCode,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
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
                'common.close'.tr(),
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

  /// نافذة صغيرة (Dialog) تأكّد للمستخدم إنو طلب الإرجاع تم إلغاؤه، بدل ما
  /// نرجعه لصفحة تفاصيل المرتجع بحالة CANCELLED.
  void _showCancelSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.xl,
            AppSizes.pagePaddingH,
            AppSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'returns.cancel_success'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.buttonBorderRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    'common.close'.tr(),
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
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

  void _showCancelDialog(BuildContext context) {
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
              'returns.cancel_confirm_title'.tr(),
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'returns.cancel_confirm_body'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.xl),
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(context); // close the confirm sheet
                setState(() => _isCancelling = true);
                final ok = await _controller.cancelReturn(widget.returnId);
                if (!mounted) return;
                setState(() => _isCancelling = false);
                if (ok) {
                  // نرجع لصفحة القائمة (Pending) بدل ما نعيد تحميل هاي
                  // الصفحة ونعرضها بحالة CANCELLED، ونظهر بدالها نافذة
                  // صغيرة تأكيدية بس. بنبعت (true) مع الـ pop حتى تعرف
                  // صفحة "My Returns" إنو لازم تعيد تحميل القائمة من
                  // الباك اند (لأن ReturnDetailView عنده نسخة منفصلة من
                  // ReturnsController، فتحديثها ما بينعكس تلقائياً على
                  // قائمة My Returns بدون هاي الإشارة).
                  final navigator = Navigator.of(context);
                  navigator.pop(true);
                  _showCancelSuccessDialog(navigator.context);
                } else {
                  setState(() {
                    _errorMessage =
                        _controller.errorMessage ??
                        'returns.cancel_failed'.tr();
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
              ),
              child: Text(
                'returns.cancel_return_request'.tr(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.buttonBorderRadius,
                  ),
                ),
              ),
              child: Text(
                'returns.go_back'.tr(),
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
}

/// Order Status banner — بيعرض الحالة الحقيقية (raw status من الباك اند)
/// بنفس نمط Container+Row+Icon+Text المستخدم بباقي شاشات التفاصيل.
class _OrderStatusBanner extends StatelessWidget {
  final String status;

  const _OrderStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = 'status.$status'.tr().toUpperCase();
    final isPending = status == 'pending';
    final color = isPending
        ? AppColors.statusPendingTxt
        : AppColors.statusShippingTxt;

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
          Icon(
            isPending ? Icons.hourglass_empty : Icons.local_shipping_outlined,
            color: color,
            size: 24,
          ),
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
}

/// Warehouse name card. Cream background, navy border, 12px radius.
class _WarehouseCard extends StatelessWidget {
  final String name;
  const _WarehouseCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardFixedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderFocused),
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
            name,
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

/// Single returned item card — name/qty/price (بدون صورة، لأن الباك اند ما
/// بيرجّع صورة ضمن resource المرتجعات).
class _ReturnItemCard extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;

  const _ReturnItemCard({
    required this.name,
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textHint,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.fieldLabel.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
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
                  'orders.quantity_label'.tr(args: [quantity.toString()]),
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
        reason.isNotEmpty ? reason : '—',
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
            'returns.your_due_money'.tr(),
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
