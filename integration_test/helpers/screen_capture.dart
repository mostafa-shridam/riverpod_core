import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Captures screens from the Flutter render layer. `takeScreenshot` on iOS
/// returns the native surface, which shows the launch screen instead of the app.
///
/// Each capture is added to `binding.reportData['screenshots']` in the shape
/// `screens_driver.dart` reads (`screenshotName`, `bytes`). The capture fails if
/// a screen is identical to an earlier one, or is too small to be a real screen.
class ScreenCapture {
  ScreenCapture(this.binding, this.tester);

  final IntegrationTestWidgetsFlutterBinding binding;
  final WidgetTester tester;
  final _captured = <String, List<int>>{};

  Future<void> shot(String name) async {
    final bytes = await tester.runAsync(_png);
    if (bytes == null) throw TestFailure('No image for $name');
    expect(
      bytes.length,
      greaterThan(20 * 1024),
      reason: '$name is too small to be a real screen',
    );
    for (final entry in _captured.entries) {
      if (_same(entry.value, bytes)) {
        fail('$name is identical to ${entry.key}: the capture is not the app');
      }
    }
    _captured[name] = bytes;

    binding.reportData ??= <String, dynamic>{};
    final screenshots =
        (binding.reportData!['screenshots'] ??= <dynamic>[]) as List<dynamic>;
    screenshots.add({'screenshotName': name, 'bytes': bytes});
  }

  /// The render layer of the first view, rasterized to PNG at device pixels.
  Future<List<int>> _png() async {
    final view = binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final pixelRatio = view.configuration.devicePixelRatio;
    final image = await layer.toImage(
      Offset.zero & view.size,
      pixelRatio: pixelRatio,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List().toList();
    } finally {
      image.dispose();
    }
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
