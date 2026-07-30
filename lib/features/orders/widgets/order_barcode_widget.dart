import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// يعرض صورة QR للطلبية اعتماداً على order_qr_code الجاي من الباك اند.
/// الصورة بتتولّد محلياً على الموبايل (مافي أي endpoint إضافي بالسيرفر).
/// السائق بيصور هاد الـ QR وقت التسليم للتأكد من مطابقة الطلبية.
class OrderBarcodeWidget extends StatelessWidget {
  final String orderQrCode;

  const OrderBarcodeWidget({super.key, required this.orderQrCode});

  @override
  Widget build(BuildContext context) {
    if (orderQrCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('باركود الطلبية', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          QrImageView(
            data: orderQrCode,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            orderQrCode,
            textAlign: TextAlign.center,
            style: AppTextStyles.fieldLabel.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'أظهر هاد الكود للسائق عند التسليم',
            style: AppTextStyles.fieldLabel.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
