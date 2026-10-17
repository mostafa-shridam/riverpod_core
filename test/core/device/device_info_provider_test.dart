import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_core/core/device/device_info_provider.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/fake_notification_backends.dart';
import '../../helpers/helpers.dart';

ProviderContainer _containerFor(PrefsStorage prefs, {int seed = 1}) =>
    createContainer(
      overrides: [
        prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
        deviceInfoSourceProvider.overrideWithValue(FakeDeviceInfoSource()),
        installationIdRandomProvider.overrideWithValue(Random(seed)),
      ],
    );

void main() {
  test('reads platform facts from the source', () async {
    final container = _containerFor(await fakePrefsStorage());

    final info = await container.read(deviceInfoProvider.future);

    expect(info.platform, 'android');
    expect(info.model, 'Pixel Test');
    expect(info.osVersion, '14');
  });

  test('creates a random install id once and keeps it', () async {
    final prefs = await fakePrefsStorage();

    final first = await _containerFor(prefs).read(deviceInfoProvider.future);
    final second = await _containerFor(
      prefs,
      seed: 2,
    ).read(deviceInfoProvider.future);

    expect(first.installationId, hasLength(32));
    expect(second.installationId, first.installationId);
  });

  test('the install id survives logout', () async {
    final prefs = await fakePrefsStorage();
    final before = await _containerFor(prefs).read(deviceInfoProvider.future);

    await prefs.clearUserScoped();

    final after = await _containerFor(
      prefs,
      seed: 3,
    ).read(deviceInfoProvider.future);
    expect(after.installationId, before.installationId);
  });

  test('different installs get different ids', () async {
    final a = await _containerFor(
      await fakePrefsStorage(),
    ).read(deviceInfoProvider.future);
    // A second install has its own store; fakePrefsStorage would share the first.
    final second = PrefsStorage(
      await Hive.openBox<dynamic>('second_install', bytes: Uint8List(0)),
    );
    final b = await _containerFor(
      second,
      seed: 2,
    ).read(deviceInfoProvider.future);

    expect(a.installationId, isNot(b.installationId));
  });
}
