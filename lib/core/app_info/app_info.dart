import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info.g.dart';

/// What the installed app says about itself. Pairs with `DeviceInfo` (the
/// device facts) when a backend call needs both.
@immutable
class AppInfo {
  const AppInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  /// Store-facing app name.
  final String name;

  /// Marketing version, for example `1.4.2`.
  final String version;

  /// Build number, for example `37`. Empty when the platform has none.
  final String buildNumber;

  /// Application id / bundle id.
  final String packageName;

  /// `1.4.2 (37)`, or just the version when there is no build number.
  String get versionLabel =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';

  @override
  bool operator ==(Object other) =>
      other is AppInfo &&
      other.name == name &&
      other.version == version &&
      other.buildNumber == buildNumber &&
      other.packageName == packageName;

  @override
  int get hashCode => Object.hash(name, version, buildNumber, packageName);
}

/// Raw app facts from the platform. Tests use a fake.
abstract interface class AppInfoSource {
  Future<AppInfo> load();
}

/// `package_info_plus` is imported here and nowhere else.
class PackageInfoPlusSource implements AppInfoSource {
  const PackageInfoPlusSource();

  @override
  Future<AppInfo> load() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      name: info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
      packageName: info.packageName,
    );
  }
}

/// Platform seam: override in tests with a fake.
@Riverpod(keepAlive: true)
AppInfoSource appInfoSource(Ref ref) => const PackageInfoPlusSource();

/// Name, version and build of the running app.
@Riverpod(keepAlive: true)
Future<AppInfo> appInfo(Ref ref) => ref.watch(appInfoSourceProvider).load();
