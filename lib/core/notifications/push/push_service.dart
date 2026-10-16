import 'dart:async';

import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_service.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';
import 'package:riverpod_core/core/notifications/push/message_deduplicator.dart';
import 'package:riverpod_core/core/notifications/push/push_backend.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';

/// Push (FCM) behaviour on top of a [PushBackend]: foreground messages, taps,
/// topics. It does nothing when push is unavailable.
class PushService {
  PushService({
    required PushBackend backend,
    required LocalNotificationService local,
    required void Function(NotificationTap tap) onTap,
    required NotificationSettings Function() settings,
    required AppLogger logger,
    required this.showForegroundWithLocal,
  }) : _backend = backend,
       _local = local,
       _onTap = onTap,
       _settings = settings,
       _logger = logger;

  final PushBackend _backend;
  final LocalNotificationService _local;
  final void Function(NotificationTap tap) _onTap;
  final NotificationSettings Function() _settings;
  final AppLogger _logger;

  /// Android shows a foreground push through a local notification (the system
  /// never shows it). iOS lets the system present it, so this is false there.
  final bool showForegroundWithLocal;

  final MessageDeduplicator _shown = MessageDeduplicator();
  final MessageDeduplicator _opened = MessageDeduplicator();
  final StreamController<PushMessage> _silent =
      StreamController<PushMessage>.broadcast();
  final List<StreamSubscription<PushMessage>> _subscriptions = [];

  bool _available = false;

  /// True after a successful [initialize].
  bool get isAvailable => _available;

  /// Data-only messages received in the foreground. The app decides what to do
  /// with them (refresh data, update a badge...).
  Stream<PushMessage> get silentMessages => _silent.stream;

  /// Starts push. Returns false (and logs once) when Firebase is not set up.
  Future<bool> initialize() async {
    _available = await _backend.initialize();
    if (!_available) {
      _logger.info(
        'Push is disabled: Firebase is not configured for this build',
      );
      return false;
    }
    _subscriptions
      ..add(_backend.onMessage.listen(_guard(_onForeground)))
      ..add(
        _backend.onMessageOpenedApp.listen(
          _guard((m) => _tap(m, NotificationTapSource.pushOpened)),
        ),
      );
    await applyForegroundPresentation();
    try {
      final initial = await _backend.initialMessage();
      if (initial != null) _tap(initial, NotificationTapSource.pushInitial);
    } on Object catch (error) {
      _logger.warning('Could not read the initial push message', error: error);
    }
    return true;
  }

  void Function(PushMessage) _guard(void Function(PushMessage) handler) =>
      (message) {
        try {
          handler(message);
        } on Object catch (error, stackTrace) {
          _logger.warning(
            'Push message handling failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      };

  void _onForeground(PushMessage message) {
    if (_shown.isDuplicate(message.id)) return;
    if (!message.hasNotification) {
      if (!_silent.isClosed) _silent.add(message);
      return;
    }
    if (!showForegroundWithLocal) return;
    final channelId = NotificationChannels.isKnown(message.channelId)
        ? message.channelId!
        : NotificationChannels.defaultChannelId;
    final payload = message.payload;
    unawaited(
      _local.showNotification(
        LocalNotification(
          id: _local.nextId(),
          title: message.title ?? '',
          body: message.body ?? '',
          channelId: channelId,
          payload: payload.isEmpty ? null : payload,
        ),
      ),
    );
  }

  void _tap(PushMessage message, NotificationTapSource source) {
    if (_opened.isDuplicate(message.id)) return;
    _onTap(NotificationTap(payload: message.payload, source: source));
  }

  /// iOS: lets the system present foreground pushes only while notifications
  /// are on in the app settings. Call after the master switch changes.
  Future<void> applyForegroundPresentation() async {
    if (!_available) return;
    try {
      await _backend.setForegroundPresentation(
        enabled: _settings().masterEnabled,
      );
    } on Object catch (error) {
      _logger.warning(
        'Could not set the foreground presentation',
        error: error,
      );
    }
  }

  /// Asks FCM for the permission (also registers with APNs on iOS).
  /// [provisional] requests quiet delivery on iOS without a prompt. Returns
  /// denied when push is unavailable.
  Future<NotificationPermissionState> requestPermission({
    bool provisional = false,
  }) async {
    if (!_available) return NotificationPermissionState.denied;
    return _backend.requestPermission(provisional: provisional);
  }

  /// Subscribes to [topic] (`[a-zA-Z0-9-_.~%]{1,900}`). False when push is
  /// unavailable or the call failed.
  Future<bool> subscribeToTopic(String topic) =>
      _topic(topic, () => _backend.subscribe(topic));

  /// Unsubscribes from [topic]. False when push is unavailable or it failed.
  Future<bool> unsubscribeFromTopic(String topic) =>
      _topic(topic, () => _backend.unsubscribe(topic));

  Future<bool> _topic(String topic, Future<void> Function() call) async {
    if (!_available) return false;
    try {
      await call();
      return true;
    } on Object catch (error) {
      _logger.warning('Topic change failed for "$topic"', error: error);
      return false;
    }
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _silent.close();
  }
}
