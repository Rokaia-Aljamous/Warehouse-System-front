import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../core/storage/token_storage.dart';
import '../features/notifications/models/notification_model.dart';
import '../features/notifications/repositories/notification_repository.dart';
import '../services/firebase_messaging_manager.dart';

/// بيلعب نفس دور DriverNotificationController بتطبيق العامل، بس بشكل
/// singleton (متل ThemeController.instance المستخدم أصلاً بهاد المشروع)
/// بدل الاعتماد على package provider — لأنه customer_app ما بيستخدم
/// Provider أصلاً بأي مكان (شفنا هيك بكل الـ Controllers الموجودة).
///
/// هيك أي شاشة أو ودجت (متل NotificationsView أو AppDrawer وقت الـ logout)
/// فيها توصل لنفس الـ instance وبنفس الحالة، بدون ما نلف شجرة الـ widgets
/// كلها بـ Provider جديد.
class NotificationController extends ChangeNotifier {
  NotificationController._internal({
    NotificationRepository? repository,
    FirebaseMessagingManager? firebase,
  }) : _repository = repository ?? NotificationRepository(),
       _firebase = firebase ?? FirebaseMessagingManager.instance;

  static final NotificationController instance =
      NotificationController._internal();

  final NotificationRepository _repository;
  final FirebaseMessagingManager _firebase;

  List<CustomerNotification> notifications = const [];
  int unreadCount = 0;
  bool isLoading = false;
  String? error;

  StreamSubscription<void>? _notificationSubscription;
  StreamSubscription<String>? _tokenSubscription;
  String? _registeredDeviceToken;
  bool _listenersAttached = false;

  List<CustomerNotification> get unreadNotifications =>
      notifications.where((item) => !item.isRead).toList();
  List<CustomerNotification> get readNotifications =>
      notifications.where((item) => item.isRead).toList();

  /// يُستدعى مرة وحدة بعد نجاح تسجيل الدخول (من HomeView.initState) —
  /// بيربط الاستماع لأحداث Firebase وبيسجل الـ device token، وبيجيب
  /// أول قائمة إشعارات.
  Future<void> initialize() async {
    if (!_listenersAttached) {
      _listenersAttached = true;
      _notificationSubscription = _firebase.notificationEvents.listen((_) {
        unawaited(refresh());
      });
      _tokenSubscription = _firebase.tokenRefresh.listen((deviceToken) {
        unawaited(_registerToken(deviceToken));
      });
    }

    await Future.wait([refresh(), _enablePushNotifications()]);
  }

  Future<void> refresh() async {
    final authToken = await TokenStorage.getToken();
    if (authToken == null) return;

    isLoading = notifications.isEmpty;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getNotifications(token: authToken),
        _repository.getUnreadCount(token: authToken),
      ]);
      notifications = results[0] as List<CustomerNotification>;
      unreadCount = results[1] as int;
    } catch (e) {
      error = e.toString();
      unreadCount = unreadNotifications.length;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(CustomerNotification notification) async {
    if (notification.isRead) return;

    final authToken = await TokenStorage.getToken();
    if (authToken == null) return;

    try {
      await _repository.markAsRead(
        token: authToken,
        notificationId: notification.id,
      );
      notifications = notifications
          .map((item) => item.id == notification.id ? item.markRead() : item)
          .toList();
      unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final authToken = await TokenStorage.getToken();
    if (authToken == null) return;

    try {
      await _repository.markAllAsRead(token: authToken);
      notifications = notifications.map((item) => item.markRead()).toList();
      unreadCount = 0;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// يُستدعى قبل مسح التوكن المحلي وقت تسجيل الخروج (من AppDrawer)
  /// — بيلغي تسجيل الجهاز بالباك اند وبيمسح الـ FCM token محلياً.
  Future<void> unregisterDevice() async {
    final authToken = await TokenStorage.getToken();
    final deviceToken = _registeredDeviceToken;

    if (authToken != null && deviceToken != null && deviceToken.isNotEmpty) {
      try {
        await _repository.unregisterDeviceToken(
          token: authToken,
          deviceToken: deviceToken,
        );
      } catch (_) {
        // ما منوقف الـ logout بسبب فشل إلغاء تسجيل الجهاز
      }
    }

    await _firebase.deleteToken();
    _registeredDeviceToken = null;
    notifications = const [];
    unreadCount = 0;
    notifyListeners();
  }

  Future<void> _enablePushNotifications() async {
    final deviceToken = await _firebase.enableForAuthenticatedCustomer();
    if (deviceToken != null && deviceToken.isNotEmpty) {
      await _registerToken(deviceToken);
    }
  }

  Future<void> _registerToken(String deviceToken) async {
    final authToken = await TokenStorage.getToken();
    if (authToken == null) return;

    final previousDeviceToken = _registeredDeviceToken;
    if (previousDeviceToken != null && previousDeviceToken != deviceToken) {
      try {
        await _repository.unregisterDeviceToken(
          token: authToken,
          deviceToken: previousDeviceToken,
        );
      } catch (_) {}
    }

    final platform = Platform.isIOS ? 'ios' : 'android';
    try {
      await _repository.registerDeviceToken(
        token: authToken,
        deviceToken: deviceToken,
        platform: platform,
      );
      _registeredDeviceToken = deviceToken;
    } catch (_) {
      // ما منكسر التطبيق لو فشل تسجيل التوكن (مثلاً لو الباك مش شغال)
    }
  }
}
