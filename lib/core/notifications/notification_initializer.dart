import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/notifications/local_notifications_service.dart';
import 'package:riverpod_core/core/notifications/remote_notifications_service.dart';

class NotificationInitializer {
  static final NotificationInitializer instance = NotificationInitializer._();
  NotificationInitializer._();

  late final LocalNotificationsService _localNotificationsService;
  late final FirebaseMessagingService _remoteNotificationsService;

  bool _notificationsEnabled = true;

  // ================= INIT =================
  Future<void> init() async {
    _notificationsEnabled = true;

    try {
      _localNotificationsService = LocalNotificationsService.instance;
      _remoteNotificationsService = FirebaseMessagingService.instance;

      await _localNotificationsService.init();

      await _remoteNotificationsService.init();
    } catch (e) {
      log('Failed to initialize notification services: $e');

      throw Exception('Failed to initialize notification services: $e');
    }
  }

  // ================= TOGGLE (Settings) =================
  Future<bool> changeNotificationPermission(bool enabled) async {
    await _localNotificationsService.toggle(enabled);
    await _remoteNotificationsService.toogle(enabled);
    _notificationsEnabled = enabled;
    return _notificationsEnabled;
  }

  bool get isEnabled => _notificationsEnabled;
}

final notificationInitializerProvider = Provider<NotificationInitializer>((
  ref,
) {
  return NotificationInitializer.instance;
});
