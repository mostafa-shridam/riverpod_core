import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/media/image_processing.dart';
import 'package:riverpod_core/core/media/media_service.dart';
import 'package:riverpod_core/core/media/picked_media.dart';

class FakePicker implements MediaPickerBackend {
  String? image;
  List<String> images = [];
  String? video;
  String? file;
  Object? error;
  int? lastMaxDimension;
  int? lastLimit;
  MediaSource? lastSource;
  Set<String>? lastExtensions;

  @override
  Future<String?> pickImage({
    required MediaSource source,
    required int maxDimension,
  }) async {
    lastSource = source;
    lastMaxDimension = maxDimension;
    if (error != null) throw error!;
    return image;
  }

  @override
  Future<List<String>> pickMultiImage({
    required int maxDimension,
    int? limit,
  }) async {
    lastMaxDimension = maxDimension;
    lastLimit = limit;
    return images;
  }

  @override
  Future<String?> pickVideo({required MediaSource source}) async {
    lastSource = source;
    return video;
  }

  @override
  Future<String?> pickFile({Set<String>? extensions}) async {
    lastExtensions = extensions;
    return file;
  }
}

class FakeCropper implements ImageCropperBackend {
  String? result;
  String? cropped;
  ImageCropStyle? style;

  @override
  Future<String?> crop(String path, {ImageCropStyle? style}) async {
    cropped = path;
    this.style = style;
    return result;
  }
}

class FakeCompressor implements ImageCompressorBackend {
  final calls = <({String path, int maxDimension, int quality})>[];
  bool fail = false;

  @override
  Future<String?> compress(
    String path, {
    required int maxDimension,
    required int quality,
  }) async {
    calls.add((path: path, maxDimension: maxDimension, quality: quality));
    return fail ? null : '$path.small.jpg';
  }
}

void main() {
  late FakePicker picker;
  late FakeCropper cropper;
  late FakeCompressor compressor;
  late MediaService service;

  setUp(() {
    picker = FakePicker();
    cropper = FakeCropper();
    compressor = FakeCompressor();
    service = MediaService(
      picker: picker,
      cropper: cropper,
      compressor: compressor,
      fileSize: (_) async => 1234,
    );
  });

  test('pickImage uses defaults 1920 / 85 and describes the result', () async {
    picker.image = '/tmp/a.png';
    final media = await service.pickImage(source: MediaSource.camera);
    expect(picker.lastSource, MediaSource.camera);
    expect(picker.lastMaxDimension, 1920);
    expect(compressor.calls.single.quality, 85);
    expect(compressor.calls.single.maxDimension, 1920);
    expect(
      media,
      const PickedMedia(
        path: '/tmp/a.png.small.jpg',
        size: 1234,
        mimeType: 'image/jpeg',
      ),
    );
    expect(cropper.cropped, isNull);
  });

  test('custom maxWidth and quality reach picker and compressor', () async {
    picker.image = '/tmp/a.jpg';
    await service.pickImage(
      source: MediaSource.gallery,
      maxWidth: 800,
      quality: 60,
    );
    expect(picker.lastMaxDimension, 800);
    expect(compressor.calls.single.maxDimension, 800);
    expect(compressor.calls.single.quality, 60);
  });

  test('pickImage returns null when the user cancels', () async {
    expect(await service.pickImage(source: MediaSource.gallery), isNull);
    expect(compressor.calls, isEmpty);
  });

  test('crop runs between pick and compress, with the style', () async {
    picker.image = '/tmp/a.jpg';
    cropper.result = '/tmp/cropped.jpg';
    const style = ImageCropStyle(
      toolbarColor: Color(0xFF000000),
      toolbarWidgetColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0xFF111111),
      activeControlsColor: Color(0xFF2222FF),
      title: 'Crop',
    );
    final media = await service.pickImage(
      source: MediaSource.gallery,
      crop: true,
      cropStyle: style,
    );
    expect(cropper.cropped, '/tmp/a.jpg');
    expect(cropper.style, style);
    expect(compressor.calls.single.path, '/tmp/cropped.jpg');
    expect(media!.path, '/tmp/cropped.jpg.small.jpg');
  });

  test('cancelled crop returns null without compressing', () async {
    picker.image = '/tmp/a.jpg';
    expect(
      await service.pickImage(source: MediaSource.gallery, crop: true),
      isNull,
    );
    expect(compressor.calls, isEmpty);
  });

  test('failed compression throws UnknownException', () async {
    picker.image = '/tmp/a.jpg';
    compressor.fail = true;
    await expectLater(
      service.pickImage(source: MediaSource.gallery),
      throwsA(isA<UnknownException>()),
    );
  });

  test('pickMultiImage compresses each, empty on cancel', () async {
    expect(await service.pickMultiImage(limit: 3), isEmpty);
    expect(picker.lastLimit, 3);
    picker.images = ['/tmp/1.jpg', '/tmp/2.png'];
    final media = await service.pickMultiImage();
    expect(media.map((m) => m.path), [
      '/tmp/1.jpg.small.jpg',
      '/tmp/2.png.small.jpg',
    ]);
    expect(compressor.calls, hasLength(2));
  });

  test('pickVideo is not compressed and keeps its mime type', () async {
    expect(await service.pickVideo(), isNull);
    picker.video = '/tmp/v.MOV';
    final media = await service.pickVideo(source: MediaSource.camera);
    expect(picker.lastSource, MediaSource.camera);
    expect(media!.mimeType, 'video/quicktime');
    expect(compressor.calls, isEmpty);
  });

  test('pickFile forwards types and describes the file', () async {
    expect(await service.pickFile(types: {'pdf'}), isNull);
    expect(picker.lastExtensions, {'pdf'});
    picker.file = '/tmp/doc.pdf';
    final media = await service.pickFile();
    expect(
      media,
      const PickedMedia(
        path: '/tmp/doc.pdf',
        size: 1234,
        mimeType: 'application/pdf',
      ),
    );
  });

  test('denied platform permission maps to ForbiddenException', () async {
    picker.error = PlatformException(code: 'camera_access_denied');
    await expectLater(
      service.pickImage(source: MediaSource.camera),
      throwsA(isA<ForbiddenException>()),
    );
  });

  test('other errors map to AppException, never raw', () async {
    picker.error = PlatformException(code: 'boom');
    await expectLater(
      service.pickImage(source: MediaSource.camera),
      throwsA(isA<UnknownException>()),
    );
    picker.error = StateError('x');
    await expectLater(
      service.pickImage(source: MediaSource.camera),
      throwsA(isA<AppException>()),
    );
  });

  test('mimeTypeOfPath: known, case-insensitive, unknown, no extension', () {
    expect(mimeTypeOfPath('/a/b/photo.JPG'), 'image/jpeg');
    expect(mimeTypeOfPath(r'C:\x\clip.mp4'), 'video/mp4');
    expect(mimeTypeOfPath('/a/file.unknownext'), 'application/octet-stream');
    expect(mimeTypeOfPath('/a.dir/file'), 'application/octet-stream');
    expect(mimeTypeOfPath('/a/file.'), 'application/octet-stream');
  });

  test('ImageCropStyle.fromTheme reads the color scheme', () {
    final theme = ThemeData(colorScheme: const ColorScheme.light());
    final style = ImageCropStyle.fromTheme(theme, title: 'T');
    expect(style.toolbarColor, theme.colorScheme.surface);
    expect(style.activeControlsColor, theme.colorScheme.primary);
    expect(style.title, 'T');
  });
}
