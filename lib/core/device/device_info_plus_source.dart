import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/device/device_info_source.dart';

/// [DeviceInfoSource] over `device_info_plus`.
class DeviceInfoPlusSource implements DeviceInfoSource {
  DeviceInfoPlusSource([DeviceInfoPlugin? plugin])
    : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  @override
  Future<String> platform() async => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'other',
  };

  @override
  Future<String> model() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return (await _plugin.androidInfo).model;
      case TargetPlatform.iOS:
        // The machine id (iPhone15,2): the user-chosen device name is
        // personal data and is not read.
        return (await _plugin.iosInfo).utsname.machine;
      default:
        return 'unknown';
    }
  }

  @override
  Future<String> osVersion() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return (await _plugin.androidInfo).version.release;
      case TargetPlatform.iOS:
        return (await _plugin.iosInfo).systemVersion;
      default:
        return 'unknown';
    }
  }
}
