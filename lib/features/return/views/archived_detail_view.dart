import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../controllers/returns_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/return_model.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

/// Archived return order detail screen — يجيب المرتجع الحقيقي حسب [returnId].
/// بيستخدم لحالات: return_to_stock / damaged (تمت الموافقة والاسترجاع فعلياً)
/// و rejected / cancelled (اتلغى أو انرفض).
class ArchivedDetailView extends StatefulWidget {
  final int returnId;

  const ArchivedDetailView({super.key, required this.returnId});

  @override
  State<ArchivedDetailView> createState() => _ArchivedDetailViewState();
}

class _ArchivedDetailViewState extends State<ArchivedDetailView> {
  final _controller = ReturnsController();
  bool _isLoading = true;
  String? _errorMessage;
  ReturnModel? _returnData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _controller.fetchReturnDetails(widget.returnId);
    if (!mounted) return;
    setState(() {
      _returnData = data;
      _isLoading = false;
      if (data == null) _errorMessage = 'returns.details_load_failed'.tr();
    });
  }

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_returnData == null) {
      return Scaffold(
        backgroundColor: AppColors.cardBg,
        body: Center(
          child: Text(
            _errorMessage ?? 'errors.unexpected'.tr(),
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }

    final data = _returnData!;
    // rejected/cancelled = لم يُقبل المرتجع فعلياً (بدون استرجاع مبلغ).
    // return_to_stock/damaged = تم استلام المرتجع فعلياً (استرجاع مبلغ).
    final isNegative = data.status == 'rejected' || data.status == 'cancelled';

    return Scaffold(
      backgroundColor: AppColors.cardBg,
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

            // ── Order Status banner ─────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color:
                    (isNegative
                            ? AppColors.statusCancelledTxt
                            : AppColors.statusApprovedTxt)
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    isNegative
                        ? Icons.cancel_outlined
                        : Icons.check_circle_outline,
                    color: isNegative
                        ? AppColors.statusCancelledTxt
                        : AppColors.statusApprovedTxt,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'status.${data.status}'.tr().toUpperCase(),
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: isNegative
                          ? AppColors.statusCancelledTxt
                          : AppColors.statusApprovedTxt,
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
                  const SizedBox(height: AppSizes.lg),

                  // ── Warehouse card ─────────────────────────────────────
                  _ArchivedWarehouseCard(
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
                      (item) => _ArchivedItemCard(
                        name: item.productName,
                        quantity: item.quantity,
                        price: item.subtotal,
                      ),
                    ),

                  const SizedBox(height: AppSizes.lg),

                  // ── RETURN REASON section ──────────────────────────────
                  Text('returns.return_reason'.tr(), style: _sectionLabelStyle),
                  const SizedBox(height: AppSizes.md),
                  _ArchivedReasonCard(reason: data.returnReason),

                  const SizedBox(height: AppSizes.lg),

                  // ── money refund / no-refund card ──────────────────────
                  _MoneyRefundCard(
                    amount: data.dueAmount,
                    isNegative: isNegative,
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
}

/// Warehouse name card. Cream background, navy border, 12px radius.
class _ArchivedWarehouseCard extends StatelessWidget {
  final String name;
  const _ArchivedWarehouseCard({required this.name});

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

/// Single archived item card — name/qty/price (بدون صورة حقيقية).
class _ArchivedItemCard extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;

  const _ArchivedItemCard({
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
class _ArchivedReasonCard extends StatelessWidget {
  final String reason;
  const _ArchivedReasonCard({required this.reason});

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

/// "money refund" card — أخضر لو تم الاسترجاع فعلياً، أحمر لو انرفض/انلغى.
class _MoneyRefundCard extends StatelessWidget {
  final double amount;
  final bool isNegative;
  const _MoneyRefundCard({required this.amount, required this.isNegative});

  @override
  Widget build(BuildContext context) {
    final color = isNegative
        ? AppColors.statusCancelledTxt
        : AppColors.statusApprovedTxt;
    final bg = isNegative
        ? AppColors.statusCancelledBg
        : AppColors.statusApprovedBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isNegative
                ? 'returns.return_not_processed'.tr()
                : 'returns.money_refund'.tr(),
            style: AppTextStyles.fieldLabel.copyWith(color: color),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
