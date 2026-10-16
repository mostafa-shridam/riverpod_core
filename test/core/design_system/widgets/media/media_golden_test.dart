import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

import '../display/ds_test_harness.dart';
import 'fake_video_backend.dart';

enum _Scene { controls, buffering, error }

Future<void> _pumpScene(
  WidgetTester tester,
  _Scene scene, {
  required String locale,
  required bool dark,
  double textScale = 1.0,
}) async {
  final factory = FakeVideoFactory(failFirst: scene == _Scene.error);
  await pumpDs(
    tester,
    Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: AppVideoPlayer(
          source: const AppVideoSource.network('https://example.com/v.mp4'),
          backendFactory: factory.call,
        ),
      ),
    ),
    locale: locale,
    dark: dark,
    textScale: textScale,
    disableAnimations: false,
  );
  await tester.pump();
  await tester.pump();
  if (scene == _Scene.buffering) {
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    factory.last.emit(isBuffering: true);
  }
  if (scene != _Scene.error) {
    factory.last.emit(
      position: const Duration(seconds: 20),
      buffered: const Duration(seconds: 35),
    );
  }
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  for (final scene in _Scene.values) {
    for (final mode in goldenModes) {
      testWidgets('golden ${scene.name} ${mode.name}', (tester) async {
        await _pumpScene(tester, scene, locale: mode.locale, dark: mode.dark);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            '../../../../goldens/media/${scene.name}_${mode.name}.png',
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('golden controls light_en at text scale 2.0', (tester) async {
    await _pumpScene(
      tester,
      _Scene.controls,
      locale: 'en',
      dark: false,
      textScale: 2,
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../../../../goldens/media/controls_light_en_x2.png'),
    );
    expect(tester.takeException(), isNull);
  });
}
