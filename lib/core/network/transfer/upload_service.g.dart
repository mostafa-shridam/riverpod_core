// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(uploadService)
final uploadServiceProvider = UploadServiceProvider._();

final class UploadServiceProvider
    extends $FunctionalProvider<UploadService, UploadService, UploadService>
    with $Provider<UploadService> {
  UploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadServiceHash();

  @$internal
  @override
  $ProviderElement<UploadService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UploadService create(Ref ref) {
    return uploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UploadService>(value),
    );
  }
}

String _$uploadServiceHash() => r'8904982defe6638c5208d09142ada252b1f02888';
