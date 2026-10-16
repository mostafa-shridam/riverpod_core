import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';

/// The number on the iOS app icon. Android derives its badge from the
/// notifications in the shade, so every method is a no-op there.
///
/// The count lives in memory: after a restart set the absolute number with
/// [set] (for example from the server) instead of relying on [increment].
class NotificationBadge {
  NotificationBadge(this._backend);

  final LocalNotificationBackend _backend;
  int _count = 0;

  /// The last number written.
  int get count => _count;

  Future<void> set(int count) async {
    _count = count < 0 ? 0 : count;
    await _backend.setBadge(_count);
  }

  Future<void> increment([int by = 1]) => set(_count + by);

  Future<void> clear() => set(0);
}
