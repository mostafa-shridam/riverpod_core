import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controls.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_labels.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_seek_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

import '../display/ds_test_harness.dart';
import 'fake_video_backend.dart';

const _labels = AppVideoLabels(
  play: 'L-play',
  pause: 'L-pause',
  replay: 'L-replay',
  mute: 'L-mute',
  unmute: 'L-unmute',
  speed: 'L-speed',
  fullscreen: 'L-full',
  exitFullscreen: 'L-exit',
  seekBar: 'L-seek',
  error: 'L-error',
  retry: 'L-retry',
);

const _source = AppVideoSource.network('https://example.com/v.mp4');

Future<void> _pumpPlayer(
  WidgetTester tester,
  FakeVideoFactory factory, {
  bool autoPlay = false,
  VoidCallback? onEnded,
  Widget? placeholder,
  String locale = 'en',
  double textScale = 1.0,
  Size size = phoneSize,
}) async {
  await pumpDs(
    tester,
    Align(
      alignment: Alignment.topCenter,
      child: AppVideoPlayer(
        source: _source,
        autoPlay: autoPlay,
        onEnded: onEnded,
        placeholder: placeholder,
        labels: _labels,
        backendFactory: factory.call,
      ),
    ),
    locale: locale,
    textScale: textScale,
    size: size,
    disableAnimations: false,
  );
  await tester.pump();
  await tester.pump();
}

Finder get _controls => find.byType(AppVideoControls);

double _chromeOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find
          .descendant(of: _controls, matching: find.byType(AnimatedOpacity))
          .first,
    )
    .opacity;

void main() {
  testWidgets('ready: shows video, play button and time, not playing', (
    tester,
  ) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);

    expect(find.byKey(const ValueKey('fake-video')), findsOneWidget);
    expect(find.byTooltip('L-play'), findsOneWidget);
    expect(find.text('0:00 / 1:00'), findsOneWidget);
    expect(factory.last.calls, isNot(contains('play')));
    expect(_chromeOpacity(tester), 1);
  });

  testWidgets('tapping play starts playback and the button becomes pause', (
    tester,
  ) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);

    await tester.tap(find.byTooltip('L-play'));
    await tester.pump();
    expect(factory.last.calls, contains('play'));
    expect(find.byTooltip('L-pause'), findsOneWidget);
  });

  testWidgets('autoPlay plays when ready', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory, autoPlay: true);
    expect(factory.last.calls, contains('play'));
  });

  testWidgets('controls auto-hide after 3 s of playing; tap shows them', (
    tester,
  ) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory, autoPlay: true);
    expect(_chromeOpacity(tester), 1);

    await tester.pump(appVideoAutoHideDelay - const Duration(seconds: 1));
    expect(_chromeOpacity(tester), 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_chromeOpacity(tester), 0);

    await tester.tapAt(tester.getCenter(find.byType(AppVideoPlayer)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_chromeOpacity(tester), 1);
    // The tap is a single tap only after the double-tap window closes.
    await tester.pump(appVideoAutoHideDelay + const Duration(seconds: 1));
    expect(_chromeOpacity(tester), 0);
  });

  testWidgets('controls stay visible while paused', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);
    await tester.pump(const Duration(seconds: 10));
    expect(_chromeOpacity(tester), 1);
  });

  testWidgets('mute toggles and shows the unmute label', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);

    await tester.tap(find.byTooltip('L-mute'));
    await tester.pump();
    expect(factory.last.calls, contains('setVolume:0.0'));
    expect(find.byTooltip('L-unmute'), findsOneWidget);

    await tester.tap(find.byTooltip('L-unmute'));
    await tester.pump();
    expect(factory.last.calls.last, 'setVolume:1.0');
  });

  testWidgets('speed menu offers 0.5/1/1.5/2 and applies the choice', (
    tester,
  ) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);

    await tester.tap(find.text('1×'));
    await tester.pumpAndSettle();
    for (final s in ['0.5×', '1.5×', '2×']) {
      expect(find.text(s), findsOneWidget);
    }
    await tester.tap(find.text('2×'));
    await tester.pumpAndSettle();
    expect(factory.last.calls, contains('setSpeed:2.0'));
    expect(find.text('2×'), findsOneWidget);
  });

  testWidgets('double tap seeks 10 s on the tapped half', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);
    final rect = tester.getRect(find.byType(AppVideoPlayer));
    final right = Offset(rect.right - 60, rect.top + 40);
    final left = Offset(rect.left + 60, rect.top + 40);

    await tester.tapAt(right);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(right);
    await tester.pump(const Duration(milliseconds: 50));
    expect(factory.last.value.position, const Duration(seconds: 10));

    await tester.pump(const Duration(seconds: 1));
    await tester.tapAt(left);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(left);
    await tester.pump(const Duration(milliseconds: 50));
    expect(factory.last.value.position, Duration.zero);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('tapping the seek bar seeks proportionally', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);
    await tester.tapAt(tester.getCenter(find.byType(AppVideoSeekBar)));
    await tester.pump();
    expect(factory.last.value.position.inSeconds, inInclusiveRange(29, 31));
  });

  testWidgets('seek bar exposes slider semantics with step actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);
    final node = tester.getSemantics(find.byType(AppVideoSeekBar));
    expect(node.label, 'L-seek');
    expect(node.value, '0:00 / 1:00');
    tester.semantics.performAction(
      find.semantics.byLabel('L-seek'),
      SemanticsAction.increase,
    );
    await tester.pump();
    expect(factory.last.value.position, const Duration(seconds: 10));
    handle.dispose();
  });

  testWidgets('error state shows message and retry recovers', (tester) async {
    final factory = FakeVideoFactory(failFirst: true);
    await _pumpPlayer(tester, factory);
    expect(find.text('L-error'), findsOneWidget);
    expect(find.byTooltip('L-play'), findsNothing);

    await tester.tap(find.text('L-retry'));
    await tester.pump();
    await tester.pump();
    expect(factory.created, hasLength(2));
    expect(find.text('L-error'), findsNothing);
    expect(find.byTooltip('L-play'), findsOneWidget);
  });

  testWidgets('initializing shows the placeholder and a spinner', (
    tester,
  ) async {
    final factory = FakeVideoFactory(holdInit: Completer<void>());
    await _pumpPlayer(
      tester,
      factory,
      placeholder: const Text('poster', key: ValueKey('poster')),
    );
    expect(find.byKey(const ValueKey('poster')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const ValueKey('fake-video')), findsNothing);
  });

  testWidgets('placeholder disappears once playing', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(
      tester,
      factory,
      placeholder: const Text('poster', key: ValueKey('poster')),
    );
    expect(find.byKey(const ValueKey('poster')), findsOneWidget);
    await tester.tap(find.byTooltip('L-play'));
    await tester.pump();
    expect(find.byKey(const ValueKey('poster')), findsNothing);
  });

  testWidgets('buffering shows a spinner while playing', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory, autoPlay: true);
    factory.last.emit(isBuffering: true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip('L-pause'), findsNothing);
    factory.last.emit(isBuffering: false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ended shows replay and calls onEnded once', (tester) async {
    var ended = 0;
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory, autoPlay: true, onEnded: () => ended++);
    factory.last.emit(position: const Duration(seconds: 60), isPlaying: false);
    await tester.pump();
    expect(ended, 1);
    expect(find.byTooltip('L-replay'), findsOneWidget);

    await tester.tap(find.byTooltip('L-replay'));
    await tester.pump();
    expect(factory.last.value.isPlaying, isTrue);
    expect(ended, 1);
  });

  testWidgets('pauses when the app goes to the background', (tester) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory, autoPlay: true);
    expect(factory.last.value.isPlaying, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(factory.last.value.isPlaying, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('disposes its own controller; leaves an external one alone', (
    tester,
  ) async {
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);
    final backend = factory.last;
    await tester.pumpWidget(const SizedBox());
    expect(backend.disposed, isTrue);

    final external = AppVideoController(_source, factory: factory.call);
    addTearDown(external.dispose);
    await external.initialize();
    await pumpDs(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: AppVideoPlayer(controller: external, labels: _labels),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    expect(factory.last.disposed, isFalse);
  });

  testWidgets('fullscreen opens a landscape route and closes again', (
    tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final factory = FakeVideoFactory();
    await _pumpPlayer(tester, factory);

    await tester.tap(find.byTooltip('L-full'));
    await tester.pumpAndSettle();
    expect(find.byType(AppVideoSurface, skipOffstage: false), findsNWidgets(2));
    expect(find.byTooltip('L-exit'), findsOneWidget);
    expect(calls, contains('SystemChrome.setPreferredOrientations'));

    await tester.tap(find.byTooltip('L-exit'));
    await tester.pumpAndSettle();
    expect(find.byType(AppVideoSurface), findsOneWidget);
    // Restore: orientations released and system UI back.
    expect(
      calls.where((c) => c == 'SystemChrome.setPreferredOrientations'),
      hasLength(2),
    );
    expect(
      calls.where((c) => c == 'SystemChrome.setEnabledSystemUIMode'),
      hasLength(2),
    );
  });

  group('layout', () {
    testWidgets('RTL: seek bar stays LTR, controls row follows direction', (
      tester,
    ) async {
      final factory = FakeVideoFactory();
      await _pumpPlayer(tester, factory, locale: 'ar');
      final seekDirection = Directionality.of(
        tester.element(
          find
              .descendant(
                of: find.byType(AppVideoSeekBar),
                matching: find.byType(CustomPaint),
              )
              .first,
        ),
      );
      expect(seekDirection, TextDirection.ltr);
      final ambient = Directionality.of(
        tester.element(find.byType(AppVideoControls)),
      );
      expect(ambient, TextDirection.rtl);
      // Fullscreen button is the last child: at the physical left in RTL.
      final fullscreen = tester.getCenter(find.byTooltip('L-full'));
      final mute = tester.getCenter(find.byTooltip('L-mute'));
      expect(fullscreen.dx, lessThan(mute.dx));
    });

    testWidgets('text scale 2.0 does not overflow on phone width', (
      tester,
    ) async {
      final factory = FakeVideoFactory();
      await _pumpPlayer(tester, factory, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet width renders without overflow', (tester) async {
      final factory = FakeVideoFactory();
      await _pumpPlayer(tester, factory, size: tabletSize);
      expect(tester.takeException(), isNull);
    });
  });

  test('formatVideoDuration uses h:mm:ss only past an hour', () {
    expect(formatVideoDuration(const Duration(seconds: 65), 'en'), '1:05');
    expect(
      formatVideoDuration(
        const Duration(hours: 1, minutes: 2, seconds: 3),
        'en',
      ),
      '1:02:03',
    );
  });
}
