import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

/// Defaults for picked images: longest side 1920 px, JPEG quality 85.
const defaultMaxImageDimension = 1920;
const defaultImageQuality = 85;

/// Colors and title of the native crop screen, built from the app theme so
/// the cropper matches the design system.
@immutable
class ImageCropStyle {
  const ImageCropStyle({
    required this.toolbarColor,
    required this.toolbarWidgetColor,
    required this.backgroundColor,
    required this.activeControlsColor,
    this.title,
  });

  /// Reads the color roles of [theme] (which is built from the design tokens).
  factory ImageCropStyle.fromTheme(ThemeData theme, {String? title}) {
    final scheme = theme.colorScheme;
    return ImageCropStyle(
      toolbarColor: scheme.surface,
      toolbarWidgetColor: scheme.onSurface,
      backgroundColor: scheme.surfaceContainerLowest,
      activeControlsColor: scheme.primary,
      title: title,
    );
  }

  final Color toolbarColor;
  final Color toolbarWidgetColor;
  final Color backgroundColor;
  final Color activeControlsColor;

  /// Already localized by the caller; null uses the platform default.
  final String? title;
}

/// Crops an image on the native UI. Returns the new file path or null when the
/// user cancels.
abstract interface class ImageCropperBackend {
  Future<String?> crop(String path, {ImageCropStyle? style});
}

/// Re-encodes an image as JPEG. Returns the new file path, or null when the
/// plugin could not produce one.
abstract interface class ImageCompressorBackend {
  Future<String?> compress(
    String path, {
    required int maxDimension,
    required int quality,
  });
}

/// [ImageCropperBackend] over `image_cropper`.
class PluginImageCropper implements ImageCropperBackend {
  const PluginImageCropper();

  @override
  Future<String?> crop(String path, {ImageCropStyle? style}) async {
    final bar = style?.toolbarColor;
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: style?.title,
          toolbarColor: bar,
          statusBarLight: bar == null
              ? null
              : ThemeData.estimateBrightnessForColor(bar) == Brightness.light,
          toolbarWidgetColor: style?.toolbarWidgetColor,
          backgroundColor: style?.backgroundColor,
          activeControlsWidgetColor: style?.activeControlsColor,
        ),
        IOSUiSettings(title: style?.title),
      ],
    );
    return cropped?.path;
  }
}

/// [ImageCompressorBackend] over `flutter_image_compress`. Writes into the app
/// cache so the picked original is never modified.
class PluginImageCompressor implements ImageCompressorBackend {
  const PluginImageCompressor();

  @override
  Future<String?> compress(
    String path, {
    required int maxDimension,
    required int quality,
  }) async {
    final dir = await getTemporaryDirectory();
    final target =
        '${dir.path}${Platform.pathSeparator}'
        'img_${DateTime.now().microsecondsSinceEpoch}.jpg';
    // The plugin only scales down; the picker already caps the longest side.
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      target,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
    );
    return result?.path;
  }
}
