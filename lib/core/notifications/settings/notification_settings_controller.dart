import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'notification_settings_controller.g.dart';

/// Owns [NotificationSettings]: loads them from the settings store and saves
/// every change. The master flag lives in `PrefsStorage.notificationsEnabled`.
@Riverpod(keepAlive: true)
class NotificationSettingsController extends _$NotificationSettingsController {
  @override
  Future<NotificationSettings> build() async {
    final prefs = await ref.watch(prefsStorageProvider.future);
    return NotificationSettings(
      masterEnabled: prefs.notificationsEnabled,
      disabledChannels: prefs.disabledNotificationChannels.toSet(),
    );
  }

  /// Saves the app-level switch.
  Future<void> setMasterEnabled({required bool value}) async {
    final prefs = await ref.read(prefsStorageProvider.future);
    await prefs.setNotificationsEnabled(value: value);
    state = AsyncData(
      (state.value ?? const NotificationSettings()).copyWith(
        masterEnabled: value,
      ),
    );
  }

  /// Saves the user's switch for one channel.
  Future<void> setChannelEnabled(
    String channelId, {
    required bool value,
  }) async {
    final prefs = await ref.read(prefsStorageProvider.future);
    final current = state.value ?? const NotificationSettings();
    final disabled = {...current.disabledChannels};
    if (value) {
      disabled.remove(channelId);
    } else {
      disabled.add(channelId);
    }
    await prefs.setDisabledNotificationChannels(disabled.toList()..sort());
    state = AsyncData(current.copyWith(disabledChannels: disabled));
  }
}
