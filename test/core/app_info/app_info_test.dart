import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';

import '../../helpers/fake_native_backends.dart';
import '../../helpers/helpers.dart';

void main() {
  const info = AppInfo(
    name: 'Demo',
    version: '1.4.2',
    buildNumber: '37',
    packageName: 'com.example.demo',
  );

  test('versionLabel joins version and build', () {
    expect(info.versionLabel, '1.4.2 (37)');
    expect(
      const AppInfo(
        name: 'a',
        version: '2.0.0',
        buildNumber: '',
        packageName: 'p',
      ).versionLabel,
      '2.0.0',
    );
  });

  test('value equality', () {
    expect(
      info,
      const AppInfo(
        name: 'Demo',
        version: '1.4.2',
        buildNumber: '37',
        packageName: 'com.example.demo',
      ),
    );
    expect(info.hashCode, info.hashCode);
  });

  test('PackageInfoPlusSource maps the platform package info', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Demo',
      packageName: 'com.example.demo',
      version: '1.4.2',
      buildNumber: '37',
      buildSignature: '',
    );

    expect(await const PackageInfoPlusSource().load(), info);
  });

  test('appInfoProvider reads the source', () async {
    final container = createContainer(
      overrides: [
        appInfoSourceProvider.overrideWithValue(FakeAppInfoSource(info)),
      ],
    );

    expect(await container.read(appInfoProvider.future), info);
  });

  test('appInfoProvider surfaces a source error', () async {
    final container = createContainer(
      overrides: [
        appInfoSourceProvider.overrideWithValue(
          FakeAppInfoSource(info, error: StateError('x')),
        ),
      ],
    );

    await expectLater(
      container.read(appInfoProvider.future),
      throwsA(isA<StateError>()),
    );
  });
}
