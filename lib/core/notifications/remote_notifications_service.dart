import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/helper/deep_link_helper.dart';
import 'package:riverpod_core/core/notifications/local_notifications_service.dart';
import 'package:riverpod_core/core/services/info_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = DeepLinkHelper.instance;
  if (message.data.isNotEmpty) {
    log('🧭 Open screen from notification: ${message.data}');
    if (message.data.containsKey('url')) {
      await handle.launchUrl(jsonEncode(message.data));
    } else {
      await handle.handleRouteById(pyload: jsonEncode(message.data));
    }
  }
}

class FirebaseMessagingService {
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  // ================= INIT =================
  Future<void> init() async {
    if (_isInitialized) return;

    _notificationsEnabled = true;
    await DeviceInfoService().saveUserDeviceData();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (_notificationsEnabled) {
      await _requestPermissions();
    }

    _setupMessageHandlers();

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    _isInitialized = true;
    log('✅ FirebaseMessagingService initialized');
  }

  // ================= PERMISSIONS =================
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('🔔 Permission status: ${settings.authorizationStatus}');
  }

  Future<void> enableNotifications() async {
    _notificationsEnabled = true;
    await _requestPermissions();
    await subscribeToTopic('all');

    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<bool> disableNotifications() async {
    _notificationsEnabled = false;
    await unsubscribeFromTopic('all');

    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }
    return _notificationsEnabled;
  }

  Future<void> toogle(bool toogle) async {
    if (toogle) {
      await enableNotifications();
    } else {
      await disableNotifications();
    }
  }

  // ================= MESSAGE HANDLERS =================
  void _setupMessageHandlers() {
    /// FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!_notificationsEnabled) {
        log('🔕 Notifications disabled – ignoring message');
        return;
      }

      log('☀️ Foreground Message: ${message.messageId}');

      if (message.notification != null) {
        await LocalNotificationsService.instance.show(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    /// BACKGROUND / OPENED APP
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!_notificationsEnabled) return;
      _handleMessage(message);
    });
  }

  // ================= NAVIGATION =================
  void _handleMessage(RemoteMessage message) async {
    final handle = DeepLinkHelper.instance;
    if (message.data.isNotEmpty) {
      log('🧭 Open screen from notification: ${message.data}');
      if (message.data.containsKey('url')) {
        await handle.launchUrl(jsonEncode(message.data));
      } else {
        await handle.handleRouteById(pyload: jsonEncode(message.data));
      }
    }
  }

  // ================= TOPICS =================
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('✅ Subscribed to $topic');
    } catch (e) {
      log('❌ Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('✅ Unsubscribed from $topic');
    } catch (e) {
      log('❌ Unsubscribe error: $e');
    }
  }
}
