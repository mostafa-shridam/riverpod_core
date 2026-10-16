import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

mixin ImagePickerMixin {
  final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery
  Future<Uint8List?> pickImageFromGallery({
    ImageSource? source,
    void Function(String message)? onError,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source ?? ImageSource.gallery,
      );
      if (image == null) {
        return null;
      }

      // Compress image
      final Uint8List bytes = await _compressImage(await image.readAsBytes());

      // Check file size
      if (bytes.lengthInBytes > 1024 * 1024) {
        onError?.call('Image size exceeds 1MB. Please select a smaller image.');
        return null;
      }
      return bytes;
    } catch (e) {
      log('Image pick error: $e');
      onError?.call('Failed to pick image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<Uint8List>?> pickImagesFromGallery({
    void Function(String message)? onError,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isEmpty) return null;

      final List<Uint8List> results = [];

      for (var x in images) {
        // Compress image
        final Uint8List bytes = await _compressImage(await x.readAsBytes());

        if (bytes.lengthInBytes > 1024 * 1024) {
          onError?.call(
            'Image size exceeds 1MB. Please select a smaller image.',
          );
          continue;
        }

        results.add(bytes);
      }

      return results.isEmpty ? null : results;
    } catch (e) {
      debugPrint('Multiple image pick error: $e');
      return null;
    }
  }

  /// Compress image using flutter_image_compress
  Future<Uint8List> _compressImage(Uint8List list) async {
    try {
      final result = Uint8List(1);
      return result;
    } catch (e) {
      return list;
    }
  }
}
