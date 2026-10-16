import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/device/device_info_provider.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_service.dart';
import 'package:riverpod_core/core/notifications/local/notification_badge.dart';
import 'package:riverpod_core/core/notifications/notification_providers.dart';
import 'package:riverpod_core/core/notifications/notification_service.dart';
import 'package:riverpod_core/core/notifications/push/push_service.dart';
import 'package:riverpod_core/core/notifications/push/push_token_manager.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router_provider.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings_controller.dart';

part 'notification_service_provider.g.dart';

/// The one [NotificationService] of the app. It follows the session: sign-in
/// registers the push token; a sign-out that was not preceded by an explicit
/// `notificationLogoutProvider` call still cleans up locally.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final logger = ref.watch(loggerProvider);
  final settingsController = notificationSettingsControllerProvider;
  NotificationSettings settings() =>
      ref.read(settingsController).value ?? const NotificationSettings();

  final localBackend = ref.watch(localNotificationBackendProvider);
  final pushBackend = ref.watch(pushBackendProvider);
  final router = ref.watch(notificationRouterProvider);

  final local = LocalNotificationService(
    backend: localBackend,
    settings: settings,
    now: ref.watch(notificationClockProvider),
    logger: logger,
  );
  final push = PushService(
    backend: pushBackend,
    local: local,
    onTap: router.handle,
    settings: settings,
    logger: logger,
    showForegroundWithLocal: defaultTargetPlatform == TargetPlatform.android,
  );
  final tokens = PushTokenManager(
    push: pushBackend,
    registrar: ref.watch(pushTokenRegistrarProvider),
    device: () => ref.read(deviceInfoProvider.future),
    isEnabled: () => settings().masterEnabled,
    logger: logger,
  );

  final service = NotificationService(
    local: local,
    badge: NotificationBadge(localBackend),
    push: push,
    router: router,
    tokens: tokens,
    permission: ref.watch(notificationPermissionFlowProvider),
    localBackend: localBackend,
    timezone: ref.watch(timezoneBackendProvider),
    label: ref.watch(notificationLabelResolverProvider),
    settings: settings,
    loadSettings: () => ref.read(settingsController.future),
    saveMaster: ({required value}) =>
        ref.read(settingsController.notifier).setMasterEnabled(value: value),
    saveChannel: (id, {required value}) => ref
        .read(settingsController.notifier)
        .setChannelEnabled(id, value: value),
    onPushAvailable: ({required available}) =>
        ref.read(pushAvailableProvider.notifier).report(available: available),
    logger: logger,
  );

  ref
    ..listen(sessionControllerProvider, (previous, next) {
      if (next == SessionStatus.signedIn) {
        unawaited(service.onSignedIn());
      } else if (previous == SessionStatus.signedIn) {
        unawaited(service.onLogout());
      }
    }, fireImmediately: true)
    ..onDispose(service.dispose);
  return service;
}

/// The logout hook for the auth feature: call and await it BEFORE
/// `clearUserData`, while the session can still authorize the server call that
/// unregisters this device from push.
///
/// ```dart
/// await ref.read(notificationLogoutProvider)();
/// await clearUserData(...);
/// ```
@Riverpod(keepAlive: true)
Future<void> Function() notificationLogout(Ref ref) =>
    ref.watch(notificationServiceProvider).onLogout;
