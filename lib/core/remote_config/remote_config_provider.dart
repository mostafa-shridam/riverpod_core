import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_repository.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

part 'remote_config_provider.g.dart';

/// Where the config comes from: the endpoint, or the built-in mock when
/// `REMOTE_CONFIG_MOCK` is set. Override in tests.
@Riverpod(keepAlive: true)
RemoteConfigSource remoteConfigSource(Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (config.remoteConfigMock) return const MockRemoteConfigSource();
  return HttpRemoteConfigSource(
    ref.watch(dioProvider),
    config.remoteConfigPath,
  );
}

@Riverpod(keepAlive: true)
RemoteConfigRepository remoteConfigRepository(Ref ref) =>
    RemoteConfigRepository(
      ref.watch(cachedRepositoryHelperProvider),
      ref.watch(remoteConfigSourceProvider),
    );

/// The config as it arrives: the cached copy first, then the server. Errors
/// when nothing is cached and the server fails.
@Riverpod(keepAlive: true)
Stream<RemoteConfig> remoteConfig(Ref ref) => ref
    .watch(remoteConfigRepositoryProvider)
    .watch()
    .map((result) => result.data);

/// The config in use: [RemoteConfig.defaults] until one is known.
@Riverpod(keepAlive: true)
RemoteConfig currentRemoteConfig(Ref ref) =>
    ref.watch(remoteConfigProvider).value ?? RemoteConfig.defaults;

/// What the app shows for this build and the config in use.
@Riverpod(keepAlive: true)
AppGateStatus appGateStatus(Ref ref) => gateStatusFor(
  currentVersion: ref.watch(appConfigProvider).appVersion,
  config: ref.watch(currentRemoteConfigProvider),
);

/// A feature flag, typed. False unless the server turns it on.
@riverpod
bool flag(Ref ref, String name) =>
    ref.watch(currentRemoteConfigProvider).flags[name] ?? false;
