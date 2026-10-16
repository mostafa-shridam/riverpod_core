// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The refresher bound by the app. [dioProvider] wraps it in a
/// [SingleFlightRefresher]. The session controller renews the tokens.

@ProviderFor(accessTokenRefresher)
final accessTokenRefresherProvider = AccessTokenRefresherProvider._();

/// The refresher bound by the app. [dioProvider] wraps it in a
/// [SingleFlightRefresher]. The session controller renews the tokens.

final class AccessTokenRefresherProvider
    extends
        $FunctionalProvider<
          AccessTokenRefresher,
          AccessTokenRefresher,
          AccessTokenRefresher
        >
    with $Provider<AccessTokenRefresher> {
  /// The refresher bound by the app. [dioProvider] wraps it in a
  /// [SingleFlightRefresher]. The session controller renews the tokens.
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
    r'ec966a02c403e398f5850b5216cb5f6352e5d688';
