// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_consent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled].

@ProviderFor(CollectionConsent)
final collectionConsentProvider = CollectionConsentProvider._();

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled].
final class CollectionConsentProvider
    extends $AsyncNotifierProvider<CollectionConsent, bool> {
  /// The runtime consent switch for crash and analytics collection. The
  /// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
  /// app shows a switch bound to [setEnabled].
  CollectionConsentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionConsentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionConsentHash();

  @$internal
  @override
  CollectionConsent create() => CollectionConsent();
}

String _$collectionConsentHash() => r'040d82b210512d1bf4b805f16cb9f4ca7fd92f19';

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled].

abstract class _$CollectionConsent extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
