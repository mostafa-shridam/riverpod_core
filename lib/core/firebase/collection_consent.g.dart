// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_consent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled]. The choice is device-level, so it
/// survives logout (see [PrefsStorage.collectionConsent]).

@ProviderFor(CollectionConsent)
final collectionConsentProvider = CollectionConsentProvider._();

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled]. The choice is device-level, so it
/// survives logout (see [PrefsStorage.collectionConsent]).
final class CollectionConsentProvider
    extends $AsyncNotifierProvider<CollectionConsent, bool> {
  /// The runtime consent switch for crash and analytics collection. The
  /// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
  /// app shows a switch bound to [setEnabled]. The choice is device-level, so it
  /// survives logout (see [PrefsStorage.collectionConsent]).
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

String _$collectionConsentHash() => r'78354608a225f4aa9ddae38c5a861cd59fccb408';

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled]. The choice is device-level, so it
/// survives logout (see [PrefsStorage.collectionConsent]).

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
