import 'package:customer_app/features/auth/widgets/app_button.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';
import 'package:customer_app/controllers/payment_controller.dart';
import 'package:customer_app/features/auth/models/order_payment_model.dart';
import 'package:customer_app/features/orders/views/paypal_webview_view.dart';

/// شاشة تأكيد ودفع طلبية معتمدة (Approved) عبر PayPal.
///
/// لازم تُفتح دايماً بـ orderId و totalPrice حقيقيين — الباك اند بيرفض
/// الدفع لأي طلبية مش بحالة "approved" بالظبط (OrderPaymentService).
class TransactionDetailsView extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final double totalPrice;

  const TransactionDetailsView({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.totalPrice,
  });

  @override
  State<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  final _controller = PaymentController();
  bool _isProcessing = false;
  bool _isCheckingExisting = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAttempt();
  }

  /// قبل ما نعرض زر الدفع، نتأكد إذا في محاولة دفع سابقة على نفس الطلب
  /// لسا شغالة (created/processing) — recovery لو التطبيق كان انسكر أو
  /// المستخدم طلع عالمتصفح ورجع بدون ما يكمل. لو لقينا وحدة منها، نكمل
  /// عليها بدل ما نبلّش create جديد (اللي ممكن يرجع 409 processing).
  Future<void> _checkExistingAttempt() async {
    final attempts = await _controller.fetchPaymentAttempts(widget.orderId);
    if (!mounted) return;

    final pending = attempts.cast<OrderPaymentModel?>().firstWhere(
      (p) =>
          p != null &&
          (p.status == 'created' || p.status == 'processing') &&
          p.approvalUrl != null,
      orElse: () => null,
    );

    setState(() => _isCheckingExisting = false);

    if (pending != null) {
      _openApprovalUrl(pending);
    }
  }

  Future<void> _startPayment() async {
    setState(() => _isProcessing = true);

    // 1) ننشئ جلسة دفع PayPal ونجيب approval_url.
    final created = await _controller.startPayPalPayment(widget.orderId);

    if (!mounted) return;

    if (created == null || created.approvalUrl == null) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'common.error_generic'.tr(),
          ),
        ),
      );
      return;
    }

    await _openApprovalUrl(created);
  }

  /// يفتح approval_url بالـ WebView (لجلسة جديدة أو محاولة سابقة لسا
  /// شغالة) ويكمل على نتيجتها بالـ capture. مشتركة بين _startPayment
  /// و _checkExistingAttempt.
  Future<void> _openApprovalUrl(OrderPaymentModel created) async {
    setState(() => _isProcessing = true);

    // 2) نفتح صفحة PayPal جوا WebView ونستنى نتيجة موافقة/إلغاء الزبون.
    final result = await Navigator.push<PayPalWebViewResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PayPalWebViewView(approvalUrl: created.approvalUrl!),
      ),
    );

    if (!mounted) return;

    if (result == null || !result.approved || result.paypalOrderId == null) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('orders.payment_cancelled'.tr())));
      return;
    }

    // 3) نأكد الدفع (capture) بعد ما الزبون وافق فعلياً بصفحة PayPal.
    final captured = await _controller.confirmPayPalPayment(
      orderId: widget.orderId,
      paypalOrderId: result.paypalOrderId!,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (captured == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'orders.payment_failed'.tr(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('orders.payment_success'.tr())));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.xl),

                  // ── عنوان ──────────────────────────────────
                  Text(
                    'orders.confirm_and_pay'.tr(),
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(widget.orderNumber, style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppSizes.xl),

                  // ── تفاصيل المعاملة (المبلغ الحقيقي فقط) ─────
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
                          'orders.transaction_details'.tr(),
                          style: AppTextStyles.fieldLabel.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        _buildRow(
                          'orders.total_amount'.tr(),
                          '\$ ${widget.totalPrice.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // ── ملاحظة PayPal ─────────────────────────────
                  Text(
                    'orders.paypal_redirect_note'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ── زر Confirm & Pay ─────────────────────────
                  AppButton(
                    label: 'orders.confirm_and_pay'.tr(),
                    fullWidth: true,
                    isLoading: _isProcessing || _isCheckingExisting,
                    onPressed: (_isProcessing || _isCheckingExisting)
                        ? null
                        : _startPayment,
                    color: AppColors.primary,
                    textColor: AppColors.textOnPrimary,
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
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
}
