// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backend seams: override in tests with fakes.

@ProviderFor(mediaPickerBackend)
final mediaPickerBackendProvider = MediaPickerBackendProvider._();

/// Backend seams: override in tests with fakes.

final class MediaPickerBackendProvider
    extends
        $FunctionalProvider<
          MediaPickerBackend,
          MediaPickerBackend,
          MediaPickerBackend
        >
    with $Provider<MediaPickerBackend> {
  /// Backend seams: override in tests with fakes.
  MediaPickerBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaPickerBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaPickerBackendHash();

  @$internal
  @override
  $ProviderElement<MediaPickerBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaPickerBackend create(Ref ref) {
    return mediaPickerBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaPickerBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaPickerBackend>(value),
    );
  }
}

String _$mediaPickerBackendHash() =>
    r'7dd7793faad474f9202cbd2c2907c25191184283';

@ProviderFor(imageCropperBackend)
final imageCropperBackendProvider = ImageCropperBackendProvider._();

final class ImageCropperBackendProvider
    extends
        $FunctionalProvider<
          ImageCropperBackend,
          ImageCropperBackend,
          ImageCropperBackend
        >
    with $Provider<ImageCropperBackend> {
  ImageCropperBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageCropperBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageCropperBackendHash();

  @$internal
  @override
  $ProviderElement<ImageCropperBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageCropperBackend create(Ref ref) {
    return imageCropperBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageCropperBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageCropperBackend>(value),
    );
  }
}

String _$imageCropperBackendHash() =>
    r'7813543d4efe45e5bf76c447b01030a1d262e0d7';

@ProviderFor(imageCompressorBackend)
final imageCompressorBackendProvider = ImageCompressorBackendProvider._();

final class ImageCompressorBackendProvider
    extends
        $FunctionalProvider<
          ImageCompressorBackend,
          ImageCompressorBackend,
          ImageCompressorBackend
        >
    with $Provider<ImageCompressorBackend> {
  ImageCompressorBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageCompressorBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageCompressorBackendHash();

  @$internal
  @override
  $ProviderElement<ImageCompressorBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageCompressorBackend create(Ref ref) {
    return imageCompressorBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageCompressorBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageCompressorBackend>(value),
    );
  }
}

String _$imageCompressorBackendHash() =>
    r'70e631e4c96a2f30060ea48ff4a7fbaa2096d78d';

/// The one [MediaService] of the app.

@ProviderFor(mediaService)
final mediaServiceProvider = MediaServiceProvider._();

/// The one [MediaService] of the app.

final class MediaServiceProvider
    extends $FunctionalProvider<MediaService, MediaService, MediaService>
    with $Provider<MediaService> {
  /// The one [MediaService] of the app.
  MediaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaServiceHash();

  @$internal
  @override
  $ProviderElement<MediaService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaService create(Ref ref) {
    return mediaService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaService>(value),
    );
  }
}

String _$mediaServiceHash() => r'b8a975292f65423c377f04c862a749c6b115302b';
