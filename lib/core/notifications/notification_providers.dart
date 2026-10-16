import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/design_system/tokens/brand_config.dart';
import 'package:riverpod_core/core/notifications/local/flutter_local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/local/native_timezone_backend.dart';
import 'package:riverpod_core/core/notifications/local/timezone_backend.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_backend.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_flow.dart';
import 'package:riverpod_core/core/notifications/permission/platform_notification_permission_backend.dart';
import 'package:riverpod_core/core/notifications/push/firebase_push_backend.dart';
import 'package:riverpod_core/core/notifications/push/push_backend.dart';
import 'package:riverpod_core/core/notifications/registration/noop_push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'notification_providers.g.dart';

/// The clock of the notification system: override in tests.
@Riverpod(keepAlive: true)
DateTime Function() notificationClock(Ref ref) => DateTime.now;

/// Resolves a `LocaleKeys` constant in the current language.
@Riverpod(keepAlive: true)
NotificationLabelResolver notificationLabelResolver(Ref ref) =>
    (key) => key.tr();

/// Platform seam for the time zone: override in tests.
@Riverpod(keepAlive: true)
TimezoneBackend timezoneBackend(Ref ref) => const NativeTimezoneBackend();

/// Platform seam for local notifications: override in tests. The accent color
/// of Android notifications is the brand seed color (design tokens).
@Riverpod(keepAlive: true)
LocalNotificationBackend localNotificationBackend(Ref ref) =>
    FlutterLocalNotificationBackend(accentColor: brandSeedColor);

/// Platform seam for push: override in tests.
@Riverpod(keepAlive: true)
PushBackend pushBackend(Ref ref) => FirebasePushBackend();

/// Platform seam for the notification permission: override in tests.
@Riverpod(keepAlive: true)
NotificationPermissionBackend notificationPermissionBackend(Ref ref) =>
    const PlatformNotificationPermissionBackend();

/// The app wires the design-system rationale dialog here. Null means the flow
/// skips the explanation and goes straight to the system prompt.
@Riverpod(keepAlive: true)
NotificationRationalePresenter? notificationRationalePresenter(Ref ref) => null;

/// The permission flow (status, rationale, system prompt, settings).
@Riverpod(keepAlive: true)
NotificationPermissionFlow notificationPermissionFlow(Ref ref) =>
    NotificationPermissionFlow(
      backend: ref.watch(notificationPermissionBackendProvider),
      presenter: ref.watch(notificationRationalePresenterProvider),
    );

/// How the app tells its backend about push tokens. The default does nothing;
/// override it with a real registrar (see `DioPushTokenRegistrar`).
@Riverpod(keepAlive: true)
PushTokenRegistrar pushTokenRegistrar(Ref ref) =>
    const NoopPushTokenRegistrar();

/// Opens a notification's `url` in the external browser.
@Riverpod(keepAlive: true)
NotificationUrlOpener notificationUrlOpener(Ref ref) =>
    (url) => launchUrl(url, mode: LaunchMode.externalApplication);

/// Whether push works in this build: false when Firebase is not configured or
/// before the startup finished. The UI hides push-only settings when false.
@Riverpod(keepAlive: true)
class PushAvailable extends _$PushAvailable {
  @override
  bool build() => false;

  // The service reports the startup result here.
  // ignore: use_setters_to_change_properties
  void report({required bool available}) => state = available;
}

/// The OS permission to show notifications. `ref.invalidate` it after the user
/// returns from the system settings.
@riverpod
Future<NotificationPermissionState> notificationPermissionState(Ref ref) =>
    ref.watch(notificationPermissionFlowProvider).status();
