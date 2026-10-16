import 'package:flutter/foundation.dart';

/// The user's own notification choices (not the OS permission).
///
/// Stored under `user.notifications.*` in the settings store, so logout wipes
/// them with the other user-scoped keys.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.masterEnabled = true,
    this.disabledChannels = const {},
  });

  /// The app-level switch. Off: nothing is shown and the device is
  /// unregistered from push on the server.
  final bool masterEnabled;

  /// Ids of channels the user switched off.
  final Set<String> disabledChannels;

  /// The user's own switch for [channelId], ignoring the master switch.
  bool isChannelSwitchOn(String channelId) =>
      !disabledChannels.contains(channelId);

  /// True when a notification on [channelId] may be shown.
  bool isChannelEnabled(String channelId) =>
      masterEnabled && isChannelSwitchOn(channelId);

  NotificationSettings copyWith({
    bool? masterEnabled,
    Set<String>? disabledChannels,
  }) => NotificationSettings(
    masterEnabled: masterEnabled ?? this.masterEnabled,
    disabledChannels: disabledChannels ?? this.disabledChannels,
  );
}
