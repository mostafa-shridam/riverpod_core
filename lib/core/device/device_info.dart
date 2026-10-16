import 'package:flutter/foundation.dart';

/// What the app may tell its backend about this device. No hardware or
/// advertising identifiers: [installationId] is a random id created on first
/// run and kept until the app is uninstalled.
@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.installationId,
  });

  /// `android`, `ios` or `other`.
  final String platform;

  /// Hardware model, for example `Pixel 8` or `iPhone15,2`.
  final String model;

  /// OS version, for example `14` or `17.4`.
  final String osVersion;

  /// Random per-install id, stable across launches and logouts.
  final String installationId;

  @override
  bool operator ==(Object other) =>
      other is DeviceInfo &&
      other.platform == platform &&
      other.model == model &&
      other.osVersion == osVersion &&
      other.installationId == installationId;

  @override
  int get hashCode => Object.hash(platform, model, osVersion, installationId);
}
