import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';

import '../../helpers/helpers.dart';

class _InstalledInfo implements AppInfoSource {
  _InstalledInfo(this.version);

  final String version;

  @override
  Future<AppInfo> load() async => AppInfo(
    name: 'Test',
    version: version,
    buildNumber: '1',
    packageName: 'test.app',
  );
}

class _Source implements RemoteConfigSource {
  _Source({this.value, this.error});

  final RemoteConfig? value;
  final Object? error;
  int fetches = 0;

  @override
  Future<CacheFetch<RemoteConfig>> fetch() async {
    fetches++;
    if (error != null) throw error!;
    return (value: value!, etag: null);
  }
}

AppConfig _config({String? appVersion = '1.0.0'}) => AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
  appVersion: appVersion,
);

ProviderContainer _container({
  required RemoteConfigSource source,
  String? appVersion = '1.0.0',
  String installedVersion = '1.0.0',
}) {
  final database = AppDatabase.inMemory();
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_config(appVersion: appVersion)),
      appDatabaseProvider.overrideWithValue(database),
      remoteConfigSourceProvider.overrideWithValue(source),
      appInfoSourceProvider.overrideWithValue(_InstalledInfo(installedVersion)),
    ],
  );
  container.listen(remoteConfigProvider, (_, _) {}, onError: (_, _) {});
  addTearDown(database.close);
  return container;
}

void main() {
  test('a flag is false unless the server turns it on', () async {
    final container = _container(
      source: _Source(
        value: const RemoteConfig(
          minVersion: '0.0.0',
          latestVersion: '0.0.0',
          flags: {'newCheckout': true},
        ),
      ),
    );
    await container.read(remoteConfigProvider.future);

    expect(container.read(flagProvider('newCheckout')), isTrue);
    expect(container.read(flagProvider('unknownFlag')), isFalse);
  });

  test('without a config the defaults apply: no gate, no flags', () async {
    final source = _Source(error: const NetworkException());
    final container = _container(source: source);
    await container
        .read(remoteConfigProvider.future)
        .then<void>((_) {}, onError: (_) {});

    expect(
      source.fetches,
      1,
      reason: 'a failed read is not retried: the config is optional',
    );
    expect(container.read(currentRemoteConfigProvider), RemoteConfig.defaults);
    expect(container.read(appGateStatusProvider), AppGateStatus.ok);
    expect(container.read(flagProvider('anything')), isFalse);
  });

  test('without an override the installed version is compared', () async {
    final container = _container(
      appVersion: null,
      installedVersion: '1.2.0',
      source: _Source(
        value: const RemoteConfig(minVersion: '1.0.0', latestVersion: '1.5.0'),
      ),
    );
    await container.read(remoteConfigProvider.future);
    await container.read(appInfoProvider.future);

    expect(container.read(currentAppVersionProvider), '1.2.0');
    expect(
      container.read(appGateStatusProvider),
      AppGateStatus.updateAvailable,
    );
  });

  test('the gate reads the version of this build', () async {
    final source = _Source(
      value: const RemoteConfig(minVersion: '1.0.0', latestVersion: '1.5.0'),
    );
    final behind = _container(source: source, appVersion: '1.2.0');
    await behind.read(remoteConfigProvider.future);
    expect(behind.read(appGateStatusProvider), AppGateStatus.updateAvailable);

    final current = _container(source: source, appVersion: '1.5.0');
    await current.read(remoteConfigProvider.future);
    expect(current.read(appGateStatusProvider), AppGateStatus.ok);
  });
}
