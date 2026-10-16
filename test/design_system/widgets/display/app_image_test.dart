import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/design_system/widgets/display/app_image.dart';

import 'ds_test_harness.dart';

/// Image provider driven by the test; never touches the network.
class FakeImageProvider extends ImageProvider<FakeImageProvider> {
  FakeImageProvider(this.completer);

  final Completer<ImageInfo> completer;

  @override
  Future<FakeImageProvider> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    FakeImageProvider key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(completer.future);
}

Future<ui.Image> _testImage(WidgetTester tester) async =>
    (await tester.runAsync(() => createTestImage(width: 8, height: 8)))!;

Finder get _shimmer => find.byType(AppImageShimmer);
Finder get _brokenIcon => find.byIcon(Icons.broken_image_outlined);

void main() {
  testWidgets('shows the shimmer while loading, then the image', (
    tester,
  ) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      Center(
        child: AppImage.provider(
          FakeImageProvider(completer),
          width: 100,
          height: 100,
        ),
      ),
    );
    expect(_shimmer, findsOneWidget);
    expect(find.byType(RawImage), findsNothing);

    completer.complete(ImageInfo(image: await _testImage(tester)));
    await tester.pump();
    await tester.pump();
    expect(_shimmer, findsNothing);
    expect(find.byType(RawImage), findsOneWidget);
  });

  testWidgets('fades the image in over the normal duration token', (
    tester,
  ) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      Center(
        child: AppImage.provider(
          FakeImageProvider(completer),
          width: 100,
          height: 100,
        ),
      ),
      disableAnimations: false,
    );
    completer.complete(ImageInfo(image: await _testImage(tester)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final mid = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AppImage),
        matching: find.byType(Opacity),
      ),
    );
    expect(mid.opacity, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 250));
    final done = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AppImage),
        matching: find.byType(Opacity),
      ),
    );
    expect(done.opacity, 1);
    // Let the shimmer ticker stop with the tree.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the error widget when loading fails', (tester) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      Center(
        child: AppImage.provider(
          FakeImageProvider(completer),
          width: 100,
          height: 100,
        ),
      ),
    );
    completer.completeError(Exception('boom'));
    await tester.pump();
    await tester.pump();
    expect(_brokenIcon, findsOneWidget);
    expect(_shimmer, findsNothing);
    expect(
      tester.widget<Icon>(_brokenIcon).semanticLabel,
      'Image could not be loaded',
    );
  });

  testWidgets('error message is localized to Arabic', (tester) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      AppImage.provider(FakeImageProvider(completer), width: 50, height: 50),
      locale: 'ar',
    );
    completer.completeError(Exception('boom'));
    await tester.pump();
    await tester.pump();
    expect(tester.widget<Icon>(_brokenIcon).semanticLabel, 'تعذر تحميل الصورة');
  });

  testWidgets('custom placeholder and error builders replace the defaults', (
    tester,
  ) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      AppImage.provider(
        FakeImageProvider(completer),
        width: 50,
        height: 50,
        placeholderBuilder: (_) => const Text('wait'),
        errorBuilder: (_) => const Text('oops'),
      ),
    );
    expect(find.text('wait'), findsOneWidget);
    expect(_shimmer, findsNothing);
    completer.completeError(Exception('boom'));
    await tester.pump();
    await tester.pump();
    expect(find.text('oops'), findsOneWidget);
  });

  testWidgets('fit, size, aspect ratio and rounding are applied', (
    tester,
  ) async {
    final completer = Completer<ImageInfo>()
      ..complete(ImageInfo(image: await _testImage(tester)));
    await pumpDs(
      tester,
      Center(
        child: SizedBox(
          width: 200,
          child: AppImage.provider(
            FakeImageProvider(completer),
            fit: BoxFit.contain,
            aspectRatio: 2,
            rounded: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
    expect(tester.getSize(find.byType(AspectRatio)), const Size(200, 100));
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('explicit borderRadius wins over rounded', (tester) async {
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      AppImage.provider(
        FakeImageProvider(completer),
        width: 50,
        height: 50,
        rounded: true,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    expect(
      tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
      BorderRadius.circular(4),
    );
  });

  testWidgets('semanticLabel is announced as an image', (tester) async {
    final handle = tester.ensureSemantics();
    final completer = Completer<ImageInfo>();
    await pumpDs(
      tester,
      AppImage.provider(
        FakeImageProvider(completer),
        width: 50,
        height: 50,
        semanticLabel: 'Profile photo',
      ),
    );
    expect(
      tester.getSemantics(find.byType(AppImage)),
      matchesSemantics(label: 'Profile photo', isImage: true),
    );
    handle.dispose();
  });

  testWidgets('the url constructor builds without touching the network', (
    tester,
  ) async {
    // Only builds the widget: image resolution is not pumped to completion.
    await pumpDs(
      tester,
      const AppImage('https://example.invalid/a.png', width: 40, height: 40),
    );
    expect(find.byType(AppImage), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shimmer animates and stops with the tree', (tester) async {
    await pumpDs(
      tester,
      const AppImageShimmer(width: 50, height: 50),
      disableAnimations: false,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(tester.hasRunningAnimations, isFalse);
  });
}
