import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/repositories/order_payment_repository.dart';

/// نتيجة جلسة الدفع اللي رجّعتها شاشة WebView: هل الزبون وافق فعلاً
/// بصفحة PayPal، وإذا وافق شو الـ paypal_order_id (اسمه "token" برابط
/// الرجوع تبع PayPal) اللي لازم نبعته لـ capture.
class PayPalWebViewResult {
  final bool approved;
  final String? paypalOrderId;

  const PayPalWebViewResult({required this.approved, this.paypalOrderId});
}

/// تعرض صفحة الدفع تبع PayPal (approval_url) جوا التطبيق.
///
/// لما PayPal يحاول يوجّه المتصفح لرابط النجاح أو الإلغاء (اللي بعتناهم
/// كـ return_url/cancel_url عند إنشاء الجلسة)، هاي الشاشة تعترض الطلب
/// *قبل* ما يتحمّل فعلياً، تستخرج paypal_order_id من الرابط، وتسكر
/// نفسها راجعة PayPalWebViewResult. هيك ما محتاجين صفحة حقيقية عالسيرفر
/// ولا أي تعديل بالباك اند.
class PayPalWebViewView extends StatefulWidget {
  final String approvalUrl;

  const PayPalWebViewView({super.key, required this.approvalUrl});

  @override
  State<PayPalWebViewView> createState() => _PayPalWebViewViewState();
}

class _PayPalWebViewViewState extends State<PayPalWebViewView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: _handleNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    if (_finished) return NavigationDecision.prevent;

    final url = request.url;

    if (url.startsWith(OrderPaymentRepository.successRedirectPrefix)) {
      _finished = true;
      // PayPal بيرجّع الـ order id بباراميتر اسمه "token" برابط النجاح.
      final paypalOrderId = Uri.parse(url).queryParameters['token'];
      _closeWith(
        PayPalWebViewResult(approved: true, paypalOrderId: paypalOrderId),
      );
      return NavigationDecision.prevent;
    }

    if (url.startsWith(OrderPaymentRepository.cancelRedirectPrefix)) {
      _finished = true;
      _closeWith(const PayPalWebViewResult(approved: false));
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _closeWith(PayPalWebViewResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'orders.confirm_and_pay'.tr(),
          style: AppTextStyles.fieldLabel.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(
            context,
          ).pop(const PayPalWebViewResult(approved: false)),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
