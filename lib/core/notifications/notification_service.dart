import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_service.dart';
import 'package:riverpod_core/core/notifications/local/notification_badge.dart';
import 'package:riverpod_core/core/notifications/local/timezone_backend.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/push/push_service.dart';
import 'package:riverpod_core/core/notifications/push/push_token_manager.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';

/// The one entry point of the notification system (see
/// `ai-docs/NOTIFICATIONS.md`): local notifications, push, permission,
/// settings, token registration and tap routing behind one object.
///
/// Built by `notificationServiceProvider`; tests build it with fakes.
class NotificationService {
  NotificationService({
    required this.local,
    required this.badge,
    required this.push,
    required this.router,
    required PushTokenManager tokens,
    required PermissionService permissions,
    required LocalNotificationBackend localBackend,
    required TimezoneBackend timezone,
    required NotificationLabelResolver label,
    required NotificationSettings Function() settings,
    required Future<void> Function() loadSettings,
    required Future<void> Function({required bool value}) saveMaster,
    required Future<void> Function(String channelId, {required bool value})
    saveChannel,
    required void Function({required bool available}) onPushAvailable,
    required AppLogger logger,
  }) : _tokens = tokens,
       _permissions = permissions,
       _localBackend = localBackend,
       _timezone = timezone,
       _label = label,
       _settings = settings,
       _loadSettings = loadSettings,
       _saveMaster = saveMaster,
       _saveChannel = saveChannel,
       _onPushAvailable = onPushAvailable,
       _logger = logger;

  /// Show, schedule and cancel local notifications.
  final LocalNotificationService local;

  /// The iOS icon badge.
  final NotificationBadge badge;

  /// Push topics, permission and silent messages.
  final PushService push;

  /// Where taps go; also exposes action-button presses.
  final NotificationRouter router;

  final PushTokenManager _tokens;
  final PermissionService _permissions;
  final LocalNotificationBackend _localBackend;
  final TimezoneBackend _timezone;
  final NotificationLabelResolver _label;
  final NotificationSettings Function() _settings;
  final Future<void> Function() _loadSettings;
  final Future<void> Function({required bool value}) _saveMaster;
  final Future<void> Function(String channelId, {required bool value})
  _saveChannel;
  final void Function({required bool available}) _onPushAvailable;
  final AppLogger _logger;

  Future<void>? _initialization;

  /// True when Firebase is configured and push works. Also exposed to the UI
  /// by `pushAvailableProvider`.
  bool get pushAvailable => push.isAvailable;

  /// Data-only pushes received in the foreground.
  Stream<PushMessage> get silentMessages => push.silentMessages;

  /// Presses of notification action buttons (for example the inline reply).
  Stream<NotificationTap> get actions => router.actions;

  /// Sets everything up once; later calls return the same future. Never
  /// throws and never shows a permission prompt: a failing part is logged and
  /// the rest keeps working (no Firebase config means local-only).
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _loadSettings();
    } on Object catch (error) {
      _logger.warning('Notification settings failed to load', error: error);
    }
    try {
      final zone = await _timezone.localTimezone() ?? 'UTC';
      await _localBackend.initialize(timezoneName: zone, onTap: router.handle);
      // Channels are NOT created here: translations are not loaded yet at
      // bootstrap, so the names would be raw keys (C-47). The
      // `NotificationLabelSync` widget creates them after the first frame.
      final launch = await _localBackend.launchTap();
      if (launch != null) router.handle(launch);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Local notifications failed to start',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      final available = await push.initialize();
      _onPushAvailable(available: available);
      if (available) _tokens.start();
    } on Object catch (error, stackTrace) {
      _onPushAvailable(available: false);
      _logger.warning(
        'Push failed to start',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Creates or renames the Android channels (and iOS action titles) in the
  /// current language. Called by `NotificationLabelSync` once translations are
  /// loaded and on every language change, and after the sign-in.
  Future<void> syncChannelLabels() async {
    try {
      await _localBackend.createChannels(
        channels: NotificationChannels.all,
        groups: NotificationChannels.groups,
        label: _label,
      );
    } on Object catch (error) {
      _logger.warning(
        'Notification channels could not be created',
        error: error,
      );
    }
  }

  /// The OS permission now, without prompting.
  Future<NotificationPermissionState> permissionState() async =>
      notificationStateOf(
        await _permissions.status(AppPermission.notifications),
      );

  /// Asks for the OS permission, explaining first when the system advises it
  /// (see [PermissionService.ensure]). On success it also finishes
  /// the push setup and registers the token.
  Future<NotificationPermissionState> ensurePermission(
    BuildContext context,
  ) async {
    final state = notificationStateOf(
      await _permissions.ensure(AppPermission.notifications, context),
    );
    if (state.isAllowed) await _afterPermissionGranted();
    return state;
  }

  /// iOS: quiet delivery without any prompt; the user can promote it later.
  /// Denied when push is unavailable.
  Future<NotificationPermissionState> requestProvisionalPermission() async {
    final state = await push.requestPermission(provisional: true);
    if (state.isAllowed) await _afterPermissionGranted();
    return state;
  }

  Future<void> _afterPermissionGranted() async {
    await push.requestPermission();
    await syncChannelLabels();
    if (push.isAvailable) {
      await _tokens.setEnabled(enabled: _settings().masterEnabled);
    }
  }

  /// Opens the system settings page of this app.
  Future<bool> openSystemSettings() => _permissions.openSettings();

  /// The app-level switch. Turning it on first makes sure the OS permission is
  /// granted when a [context] is given; false is returned (and the switch stays
  /// off) when the user declines. Turning it off cancels scheduled
  /// notifications and unregisters the device from push on the server.
  Future<bool> setEnabled({
    required bool enabled,
    BuildContext? context,
  }) async {
    if (enabled && context != null) {
      final state = await ensurePermission(context);
      if (!state.isAllowed) return false;
    }
    await _saveMaster(value: enabled);
    await push.applyForegroundPresentation();
    if (push.isAvailable) await _tokens.setEnabled(enabled: enabled);
    if (!enabled) await local.cancelAll();
    return true;
  }

  /// The user's switch for one channel of [NotificationChannels.all].
  Future<void> setChannelEnabled(String channelId, {required bool enabled}) =>
      _saveChannel(channelId, value: enabled);

  /// The user signed in: register the push token with the backend.
  Future<void> onSignedIn() async {
    await initialize();
    await syncChannelLabels();
    if (push.isAvailable) await _tokens.onSignedIn();
  }

  /// The user is signing out: unregister the token, delete it, cancel
  /// scheduled notifications and clear the badge. The auth feature calls this
  /// (through `notificationLogoutProvider`) BEFORE `clearUserData`, while the
  /// session can still authorize the unregister call.
  Future<void> onLogout() async {
    try {
      if (push.isAvailable) await _tokens.onLogout();
      await local.cancelAll();
      await badge.clear();
    } on Object catch (error) {
      _logger.warning('Notification logout cleanup failed', error: error);
    }
  }

  Future<void> dispose() async {
    await _tokens.dispose();
    await push.dispose();
  }
}
