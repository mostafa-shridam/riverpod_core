// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_links.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam: override in tests with a fake.

@ProviderFor(linkBackend)
final linkBackendProvider = LinkBackendProvider._();

/// Platform seam: override in tests with a fake.

final class LinkBackendProvider
    extends $FunctionalProvider<LinkBackend, LinkBackend, LinkBackend>
    with $Provider<LinkBackend> {
  /// Platform seam: override in tests with a fake.
  LinkBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkBackendHash();

  @$internal
  @override
  $ProviderElement<LinkBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkBackend create(Ref ref) {
    return linkBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkBackend>(value),
    );
  }
}

String _$linkBackendHash() => r'd82ee98ff984c25388ca02b083811541a48e7908';

/// The one way features open external links.

@ProviderFor(externalLinks)
final externalLinksProvider = ExternalLinksProvider._();

/// The one way features open external links.

final class ExternalLinksProvider
    extends $FunctionalProvider<ExternalLinks, ExternalLinks, ExternalLinks>
    with $Provider<ExternalLinks> {
  /// The one way features open external links.
  ExternalLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalLinksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalLinksHash();

  @$internal
  @override
  $ProviderElement<ExternalLinks> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExternalLinks create(Ref ref) {
    return externalLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExternalLinks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExternalLinks>(value),
    );
  }
}

String _$externalLinksHash() => r'5ba6a64ac56ac3c502f5ea9836ca55b18ae6d466';
