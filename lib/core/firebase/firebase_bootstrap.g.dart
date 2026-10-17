// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_bootstrap.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Default initializer: the native config files decide whether it works.

@ProviderFor(firebaseInitializer)
final firebaseInitializerProvider = FirebaseInitializerProvider._();

/// Default initializer: the native config files decide whether it works.

final class FirebaseInitializerProvider
    extends
        $FunctionalProvider<
          FirebaseInitializer,
          FirebaseInitializer,
          FirebaseInitializer
        >
    with $Provider<FirebaseInitializer> {
  /// Default initializer: the native config files decide whether it works.
  FirebaseInitializerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseInitializerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseInitializerHash();

  @$internal
  @override
  $ProviderElement<FirebaseInitializer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseInitializer create(Ref ref) {
    return firebaseInitializer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseInitializer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseInitializer>(value),
    );
  }
}

String _$firebaseInitializerHash() =>
    r'845de1eacc27f5afe3ef481ffb549b0855fb58e9';

/// The one [FirebaseBootstrap] of the app.

@ProviderFor(firebaseBootstrap)
final firebaseBootstrapProvider = FirebaseBootstrapProvider._();

/// The one [FirebaseBootstrap] of the app.

final class FirebaseBootstrapProvider
    extends
        $FunctionalProvider<
          FirebaseBootstrap,
          FirebaseBootstrap,
          FirebaseBootstrap
        >
    with $Provider<FirebaseBootstrap> {
  /// The one [FirebaseBootstrap] of the app.
  FirebaseBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseBootstrapHash();

  @$internal
  @override
  $ProviderElement<FirebaseBootstrap> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseBootstrap create(Ref ref) {
    return firebaseBootstrap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseBootstrap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseBootstrap>(value),
    );
  }
}

String _$firebaseBootstrapHash() => r'caad5eed3f570a9ace88f3490d0612fef7034a7a';

/// Whether Firebase started. False until `initObservability` ran, and when
/// the app has no Firebase files. Crash and analytics pick their vendor
/// implementation from it.

@ProviderFor(FirebaseAvailable)
final firebaseAvailableProvider = FirebaseAvailableProvider._();

/// Whether Firebase started. False until `initObservability` ran, and when
/// the app has no Firebase files. Crash and analytics pick their vendor
/// implementation from it.
final class FirebaseAvailableProvider
    extends $NotifierProvider<FirebaseAvailable, bool> {
  /// Whether Firebase started. False until `initObservability` ran, and when
  /// the app has no Firebase files. Crash and analytics pick their vendor
  /// implementation from it.
  FirebaseAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAvailableHash();

  @$internal
  @override
  FirebaseAvailable create() => FirebaseAvailable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$firebaseAvailableHash() => r'b19e6d6ebda6e9f2c0c8ed2eba47f9d13fb2cfe6';

/// Whether Firebase started. False until `initObservability` ran, and when
/// the app has no Firebase files. Crash and analytics pick their vendor
/// implementation from it.

abstract class _$FirebaseAvailable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
