// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam: override in tests with a fake.

@ProviderFor(shareBackend)
final shareBackendProvider = ShareBackendProvider._();

/// Platform seam: override in tests with a fake.

final class ShareBackendProvider
    extends $FunctionalProvider<ShareBackend, ShareBackend, ShareBackend>
    with $Provider<ShareBackend> {
  /// Platform seam: override in tests with a fake.
  ShareBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareBackendHash();

  @$internal
  @override
  $ProviderElement<ShareBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareBackend create(Ref ref) {
    return shareBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareBackend>(value),
    );
  }
}

String _$shareBackendHash() => r'047e0b87927ada27b5842a5f89a6d830c4e5e002';

/// The one way features open the share sheet.

@ProviderFor(shareService)
final shareServiceProvider = ShareServiceProvider._();

/// The one way features open the share sheet.

final class ShareServiceProvider
    extends $FunctionalProvider<ShareService, ShareService, ShareService>
    with $Provider<ShareService> {
  /// The one way features open the share sheet.
  ShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareServiceHash();

  @$internal
  @override
  $ProviderElement<ShareService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareService create(Ref ref) {
    return shareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareService>(value),
    );
  }
}

String _$shareServiceHash() => r'a4837f632dd3f025c0b1f5f3615fc8ca882798a9';
