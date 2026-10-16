import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/device/device_info.dart';
import 'package:riverpod_core/core/device/device_info_plus_source.dart';
import 'package:riverpod_core/core/device/device_info_source.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'device_info_provider.g.dart';

/// Settings key of the install id. Not under `user.`: it is a device setting
/// and survives logout.
const installationIdKey = 'device.installationId';

/// A random 128-bit id as 32 hex characters.
String generateInstallationId(Random random) => List.generate(
  16,
  (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// Platform seam: override in tests with a fake.
@Riverpod(keepAlive: true)
DeviceInfoSource deviceInfoSource(Ref ref) => DeviceInfoPlusSource();

/// Source of randomness for the install id: override in tests.
@Riverpod(keepAlive: true)
Random installationIdRandom(Ref ref) => Random.secure();

/// The device facts the app may send to its backend (for example when
/// registering a push token).
@Riverpod(keepAlive: true)
Future<DeviceInfo> deviceInfo(Ref ref) async {
  final source = ref.watch(deviceInfoSourceProvider);
  final prefs = await ref.watch(prefsStorageProvider.future);
  var stored = prefs.getStringList(installationIdKey);
  if (stored.isEmpty) {
    stored = [generateInstallationId(ref.watch(installationIdRandomProvider))];
    await prefs.setStringList(installationIdKey, stored);
  }
  return DeviceInfo(
    platform: await source.platform(),
    model: await source.model(),
    osVersion: await source.osVersion(),
    installationId: stored.first,
  );
}
