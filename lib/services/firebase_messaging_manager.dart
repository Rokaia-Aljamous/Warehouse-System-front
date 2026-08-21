import 'dart:async';

import 'package:customer_app/services/firebase_bootstrap_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// نفس منطق firebase_messaging_manager.dart بتطبيق العامل تماماً، بس:
/// - اسم الـ channel صار warehouse_customer_notifications (بدل driver)
/// - enableForAuthenticatedCustomer() بدل enableForAuthenticatedDriver()
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    final options = FirebaseBootstrapOptions.currentPlatform;
    if (options == null) {
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(options: options);
    }
  }
}

class FirebaseMessagingManager {
  FirebaseMessagingManager._();

  static final FirebaseMessagingManager instance = FirebaseMessagingManager._();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'warehouse_customer_notifications',
    'Customer Notifications',
    description: 'Order updates and account notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<void> _notificationEvents =
      StreamController<void>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  bool _initialized = false;
  bool _ready = false;

  bool get isReady => _ready;
  Stream<void> get notificationEvents => _notificationEvents.stream;
  Stream<String> get tokenRefresh => _ready
      ? FirebaseMessaging.instance.onTokenRefresh
      : const Stream<String>.empty();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final options = FirebaseBootstrapOptions.currentPlatform;
      if (Firebase.apps.isEmpty) {
        if (options == null) {
          await Firebase.initializeApp();
        } else {
          await Firebase.initializeApp(options: options);
        }
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _initializeLocalNotifications();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        _notificationEvents.add(null);
        if (defaultTargetPlatform == TargetPlatform.android) {
          unawaited(_showForegroundNotification(message));
        }
      });
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((_) {
        _notificationEvents.add(null);
      });

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        _notificationEvents.add(null);
      }

      _ready = true;
    } on Exception catch (error) {
      _ready = false;
      debugPrint(
        'Firebase Messaging is waiting for project configuration: $error',
      );
    }
  }

  /// بيطلب صلاحية الإشعارات ويرجع الـ FCM token — يُستدعى بعد نجاح
  /// تسجيل دخول الزبون (من NotificationController.initialize()).
  Future<String?> enableForAuthenticatedCustomer() async {
    if (!_ready) return null;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return null;
    }

    return FirebaseMessaging.instance.getToken();
  }

  Future<void> deleteToken() async {
    if (_ready) await FirebaseMessaging.instance.deleteToken();
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) => _notificationEvents.add(null),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final id =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    await _localNotifications.show(
      id & 0x7fffffff,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'warehouse_customer_notifications',
          'Customer Notifications',
          channelDescription: 'Order updates and account notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _notificationEvents.close();
  }
}
