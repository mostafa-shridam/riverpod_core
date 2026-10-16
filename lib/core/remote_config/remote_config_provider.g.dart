// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the config comes from: the endpoint, or the built-in mock when
/// `REMOTE_CONFIG_MOCK` is set. Override in tests.

@ProviderFor(remoteConfigSource)
final remoteConfigSourceProvider = RemoteConfigSourceProvider._();

/// Where the config comes from: the endpoint, or the built-in mock when
/// `REMOTE_CONFIG_MOCK` is set. Override in tests.

final class RemoteConfigSourceProvider
    extends
        $FunctionalProvider<
          RemoteConfigSource,
          RemoteConfigSource,
          RemoteConfigSource
        >
    with $Provider<RemoteConfigSource> {
  /// Where the config comes from: the endpoint, or the built-in mock when
  /// `REMOTE_CONFIG_MOCK` is set. Override in tests.
  RemoteConfigSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigSourceHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigSource create(Ref ref) {
    return remoteConfigSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigSource>(value),
    );
  }
}

String _$remoteConfigSourceHash() =>
    r'8a2e71a33af2f9377d1207fa247b12f1267d44be';

@ProviderFor(remoteConfigRepository)
final remoteConfigRepositoryProvider = RemoteConfigRepositoryProvider._();

final class RemoteConfigRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteConfigRepository,
          RemoteConfigRepository,
          RemoteConfigRepository
        >
    with $Provider<RemoteConfigRepository> {
  RemoteConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigRepository create(Ref ref) {
    return remoteConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigRepository>(value),
    );
  }
}

String _$remoteConfigRepositoryHash() =>
    r'228c701a60ae6a38e47c32d416f0a457733e599e';

/// The config as it arrives: the cached copy first, then the server. Errors
/// when nothing is cached and the server fails.

@ProviderFor(remoteConfig)
final remoteConfigProvider = RemoteConfigProvider._();

/// The config as it arrives: the cached copy first, then the server. Errors
/// when nothing is cached and the server fails.

final class RemoteConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<RemoteConfig>,
          RemoteConfig,
          Stream<RemoteConfig>
        >
    with $FutureModifier<RemoteConfig>, $StreamProvider<RemoteConfig> {
  /// The config as it arrives: the cached copy first, then the server. Errors
  /// when nothing is cached and the server fails.
  RemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigHash();

  @$internal
  @override
  $StreamProviderElement<RemoteConfig> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RemoteConfig> create(Ref ref) {
    return remoteConfig(ref);
  }
}

String _$remoteConfigHash() => r'f98ffd5c42d54d282aa9838f0bcf6cfdfd4223c8';

/// The config in use: [RemoteConfig.defaults] until one is known.

@ProviderFor(currentRemoteConfig)
final currentRemoteConfigProvider = CurrentRemoteConfigProvider._();

/// The config in use: [RemoteConfig.defaults] until one is known.

final class CurrentRemoteConfigProvider
    extends $FunctionalProvider<RemoteConfig, RemoteConfig, RemoteConfig>
    with $Provider<RemoteConfig> {
  /// The config in use: [RemoteConfig.defaults] until one is known.
  CurrentRemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentRemoteConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentRemoteConfigHash();

  @$internal
  @override
  $ProviderElement<RemoteConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoteConfig create(Ref ref) {
    return currentRemoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfig>(value),
    );
  }
}

String _$currentRemoteConfigHash() =>
    r'a004404f0511800eb7b3a908223adc9d1eae3fde';

/// What the app shows for this build and the config in use.

@ProviderFor(appGateStatus)
final appGateStatusProvider = AppGateStatusProvider._();

/// What the app shows for this build and the config in use.

final class AppGateStatusProvider
    extends $FunctionalProvider<AppGateStatus, AppGateStatus, AppGateStatus>
    with $Provider<AppGateStatus> {
  /// What the app shows for this build and the config in use.
  AppGateStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appGateStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appGateStatusHash();

  @$internal
  @override
  $ProviderElement<AppGateStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppGateStatus create(Ref ref) {
    return appGateStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppGateStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppGateStatus>(value),
    );
  }
}

String _$appGateStatusHash() => r'7b82f68c092bfedc7616fdd0626572d754dc543d';

/// A feature flag, typed. False unless the server turns it on.

@ProviderFor(flag)
final flagProvider = FlagFamily._();

/// A feature flag, typed. False unless the server turns it on.

final class FlagProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// A feature flag, typed. False unless the server turns it on.
  FlagProvider._({
    required FlagFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flagProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flagHash();

  @override
  String toString() {
    return r'flagProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return flag(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FlagProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flagHash() => r'0616992a8f1c9bb0ad162f23f7c72233ccbb22da';

/// A feature flag, typed. False unless the server turns it on.

final class FlagFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  FlagFamily._()
    : super(
        retry: null,
        name: r'flagProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A feature flag, typed. False unless the server turns it on.

  FlagProvider call(String name) => FlagProvider._(argument: name, from: this);

  @override
  String toString() => r'flagProvider';
}
