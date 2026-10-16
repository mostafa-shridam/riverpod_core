import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/device/device_info.dart';

/// What the backend receives to reach this install.
@immutable
class PushTokenRegistration {
  const PushTokenRegistration({
    required this.token,
    required this.device,
    this.previousToken,
  });

  /// The FCM token.
  final String token;
  final DeviceInfo device;

  /// The token this install had before a refresh; the server can drop it.
  final String? previousToken;
}
