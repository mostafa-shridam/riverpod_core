import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/media/image_processing.dart';
import 'package:riverpod_core/core/media/picked_media.dart';

part 'media_service.g.dart';

/// Where an image or video comes from.
enum MediaSource { camera, gallery }

/// The picker plugins, as plain paths. Tests implement it with a fake.
abstract interface class MediaPickerBackend {
  Future<String?> pickImage({
    required MediaSource source,
    required int maxDimension,
  });

  Future<List<String>> pickMultiImage({required int maxDimension, int? limit});

  Future<String?> pickVideo({required MediaSource source});

  /// [extensions] without the dot; null means any file.
  Future<String?> pickFile({Set<String>? extensions});
}

/// [MediaPickerBackend] over `image_picker` (system photo picker on Android,
/// so no storage permission) and `file_picker`.
class PluginMediaPicker implements MediaPickerBackend {
  const PluginMediaPicker();

  ImageSource _source(MediaSource source) => switch (source) {
    MediaSource.camera => ImageSource.camera,
    MediaSource.gallery => ImageSource.gallery,
  };

  @override
  Future<String?> pickImage({
    required MediaSource source,
    required int maxDimension,
  }) async {
    final file = await ImagePicker().pickImage(
      source: _source(source),
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
    );
    return file?.path;
  }

  @override
  Future<List<String>> pickMultiImage({
    required int maxDimension,
    int? limit,
  }) async {
    final files = await ImagePicker().pickMultiImage(
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
      limit: limit,
    );
    return [for (final f in files) f.path];
  }

  @override
  Future<String?> pickVideo({required MediaSource source}) async {
    final file = await ImagePicker().pickVideo(source: _source(source));
    return file?.path;
  }

  @override
  Future<String?> pickFile({Set<String>? extensions}) async {
    final file = await FilePicker.pickFile(
      type: extensions == null ? FileType.any : FileType.custom,
      allowedExtensions: extensions?.toList(),
    );
    return file?.path;
  }
}

/// Picks, crops and compresses media. Every method returns null when the user
/// cancels and throws an [AppException] on failure.
class MediaService {
  const MediaService({
    this.picker = const PluginMediaPicker(),
    this.cropper = const PluginImageCropper(),
    this.compressor = const PluginImageCompressor(),
    this.fileSize = _fileLength,
  });

  final MediaPickerBackend picker;
  final ImageCropperBackend cropper;
  final ImageCompressorBackend compressor;

  /// Size of a file in bytes; injectable so tests need no real files.
  final Future<int> Function(String path) fileSize;

  /// One image from the camera or gallery, optionally cropped, then resized
  /// to at most [maxWidth] px on the longest side and re-encoded at [quality].
  Future<PickedMedia?> pickImage({
    required MediaSource source,
    bool crop = false,
    int maxWidth = defaultMaxImageDimension,
    int quality = defaultImageQuality,
    ImageCropStyle? cropStyle,
  }) => _guard(() async {
    var path = await picker.pickImage(source: source, maxDimension: maxWidth);
    if (path == null) return null;
    if (crop) {
      path = await cropper.crop(path, style: cropStyle);
      if (path == null) return null;
    }
    return _process(path, maxWidth, quality);
  });

  /// Several gallery images, each resized and re-encoded. Empty when
  /// cancelled.
  Future<List<PickedMedia>> pickMultiImage({
    int maxWidth = defaultMaxImageDimension,
    int quality = defaultImageQuality,
    int? limit,
  }) => _guard(() async {
    final paths = await picker.pickMultiImage(
      maxDimension: maxWidth,
      limit: limit,
    );
    return [for (final path in paths) await _process(path, maxWidth, quality)];
  });

  /// A video from the camera or gallery, as is (no transcoding).
  Future<PickedMedia?> pickVideo({MediaSource source = MediaSource.gallery}) =>
      _guard(() async {
        final path = await picker.pickVideo(source: source);
        return path == null ? null : _describe(path);
      });

  /// Any file, optionally limited to [types] (extensions without the dot).
  Future<PickedMedia?> pickFile({Set<String>? types}) => _guard(() async {
    final path = await picker.pickFile(extensions: types);
    return path == null ? null : _describe(path);
  });

  Future<PickedMedia> _process(String path, int maxWidth, int quality) async {
    final out = await compressor.compress(
      path,
      maxDimension: maxWidth,
      quality: quality,
    );
    if (out == null) {
      throw const UnknownException(message: 'Image compression failed');
    }
    return _describe(out);
  }

  Future<PickedMedia> _describe(String path) async => PickedMedia(
    path: path,
    size: await fileSize(path),
    mimeType: mimeTypeOfPath(path),
  );

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on AppException {
      rethrow;
    } on PlatformException catch (e, st) {
      // image_picker reports a denied camera/photo permission this way.
      if (e.code.endsWith('access_denied')) {
        throw ForbiddenException(
          message: 'Media access denied: ${e.code}',
          cause: e,
          stackTrace: st,
        );
      }
      throw mapError(e, st);
    } on Object catch (e, st) {
      throw mapError(e, st);
    }
  }
}

Future<int> _fileLength(String path) => File(path).length();

/// Backend seams: override in tests with fakes.
@Riverpod(keepAlive: true)
MediaPickerBackend mediaPickerBackend(Ref ref) => const PluginMediaPicker();

@Riverpod(keepAlive: true)
ImageCropperBackend imageCropperBackend(Ref ref) => const PluginImageCropper();

@Riverpod(keepAlive: true)
ImageCompressorBackend imageCompressorBackend(Ref ref) =>
    const PluginImageCompressor();

/// The one [MediaService] of the app.
@Riverpod(keepAlive: true)
MediaService mediaService(Ref ref) => MediaService(
  picker: ref.watch(mediaPickerBackendProvider),
  cropper: ref.watch(imageCropperBackendProvider),
  compressor: ref.watch(imageCompressorBackendProvider),
);
