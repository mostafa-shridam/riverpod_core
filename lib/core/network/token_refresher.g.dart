// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single-flight refresher used by [dioProvider].

@ProviderFor(accessTokenRefresher)
final accessTokenRefresherProvider = AccessTokenRefresherProvider._();

/// The single-flight refresher used by [dioProvider].

final class AccessTokenRefresherProvider
    extends
        $FunctionalProvider<
          AccessTokenRefresher,
          AccessTokenRefresher,
          AccessTokenRefresher
        >
    with $Provider<AccessTokenRefresher> {
  /// The single-flight refresher used by [dioProvider].
  AccessTokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accessTokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accessTokenRefresherHash();

  @$internal
  @override
  $ProviderElement<AccessTokenRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccessTokenRefresher create(Ref ref) {
    return accessTokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccessTokenRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccessTokenRefresher>(value),
    );
  }
}

String _$accessTokenRefresherHash() =>
    r'75d352df25f980c45a44f87e3ced9b06b0609a1b';
