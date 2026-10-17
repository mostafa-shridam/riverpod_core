import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config.freezed.dart';
part 'remote_config.g.dart';

/// Maintenance window from the server. While [enabled], the app shows the
/// maintenance page instead of its content.
@freezed
abstract class RemoteMaintenance with _$RemoteMaintenance {
  const factory RemoteMaintenance({
    @Default(false) bool enabled,
    String? message,
  }) = _RemoteMaintenance;

  factory RemoteMaintenance.fromJson(Map<String, dynamic> json) =>
      _$RemoteMaintenanceFromJson(json);
}

/// Server-side switches read at startup (D-040): versions, maintenance and
/// feature flags. One JSON document from one endpoint.
@freezed
abstract class RemoteConfig with _$RemoteConfig {
  const factory RemoteConfig({
    /// Oldest version allowed to run. Older builds get the force update page.
    required String minVersion,

    /// Newest published version. Older builds get a dismissible update notice.
    required String latestVersion,

    /// Where the store page is; the update pages open it.
    String? storeUrl,
    @Default(RemoteMaintenance()) RemoteMaintenance maintenance,

    /// Feature flags by name. A missing flag reads as false.
    @Default(<String, bool>{}) Map<String, bool> flags,
  }) = _RemoteConfig;

  factory RemoteConfig.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigFromJson(json);

  /// Used when nothing is cached and the server cannot be reached: no gate and
  /// no flags, so the app stays usable.
  static const defaults = RemoteConfig(
    minVersion: '0.0.0',
    latestVersion: '0.0.0',
  );
}
