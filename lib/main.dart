import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:customer_app/core/storage/token_storage.dart';
import 'package:customer_app/features/auth/views/login_view.dart';
import 'package:customer_app/features/home/views/home_view.dart';
import 'package:customer_app/features/auth/views/create_password_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// مفتاح عام للـ Navigator عشان نقدر نتنقل من خارج الـ widget tree
/// (مثلاً لما نستقبل deep link بـ main.dart)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // 1) نستنى روابط جديدة (lifecycle: التطبيق بالخلفية وفتح عبر deep link)
    _linkSub = _appLinks.uriLinkStream.listen(_handleDeepLink);

    // 2) نتحقق إذا التطبيق فُتح أصلاً عن طريق deep link (cold start)
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      _handleDeepLink(uri);
    } catch (e) {
      // ما في مشكلة لو ما في رابط أولي
    }
  }

  /// بيعالج أي deep link يجي من نوع: customerapp://auth?token=XXX
  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;

    debugPrint('🔗 [DeepLink] Received: $uri');

    if (uri.scheme == 'customerapp' && uri.host == 'auth') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // نحفظ الـ token ونتنقل للـ HomeView
        TokenStorage.saveToken(token).then((_) {
          debugPrint('✅ [DeepLink] Token saved, navigating to HomeView');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
            (route) => false,
          );
        });
      } else {
        debugPrint('❌ [DeepLink] No token in URI');
      }
    } else if (uri.scheme == 'customerapp' && uri.host == 'password-reset') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      if (token != null && token.isNotEmpty && email != null && email.isNotEmpty) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CreateNewPasswordView(email: email, token: token),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Hub',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      // ── إعدادات الترجمة (easy_localization) ────────────────────────
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E3A5F),
      ),
      home: const LoginView(),
    );
  }
}
