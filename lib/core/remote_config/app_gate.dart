import 'package:riverpod_core/core/remote_config/app_version.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';

/// What the app shows for the current version and the remote config.
enum AppGateStatus { ok, updateAvailable, updateRequired, maintenance }

/// The gate decision. Pure: no UI, no I/O.
///
/// - maintenance on: [AppGateStatus.maintenance] (wins over updates);
/// - [currentVersion] unknown (still loading) or unreadable: no version check,
///   so [AppGateStatus.ok] (an unknown version never forces an update);
/// - older than `minVersion`: [AppGateStatus.updateRequired];
/// - older than `latestVersion`: [AppGateStatus.updateAvailable];
/// - otherwise [AppGateStatus.ok].
AppGateStatus gateStatusFor({
  required String? currentVersion,
  required RemoteConfig config,
}) {
  if (config.maintenance.enabled) return AppGateStatus.maintenance;
  if (currentVersion == null) return AppGateStatus.ok;
  try {
    if (compareVersions(currentVersion, config.minVersion) < 0) {
      return AppGateStatus.updateRequired;
    }
    if (compareVersions(currentVersion, config.latestVersion) < 0) {
      return AppGateStatus.updateAvailable;
    }
  } on FormatException {
    return AppGateStatus.ok;
  }
  return AppGateStatus.ok;
}

/// The soft update notice shows once per newest version: not again after the
/// user dismissed that version.
bool softUpdateDue({
  required AppGateStatus status,
  required String latestVersion,
  required Iterable<String> dismissedVersions,
}) =>
    status == AppGateStatus.updateAvailable &&
    !dismissedVersions.contains(latestVersion);
