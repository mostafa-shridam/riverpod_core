import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

import 'fake_video_backend.dart';

void main() {
  const source = AppVideoSource.network('https://example.com/v.mp4');

  late FakeVideoFactory factory;
  late AppVideoController controller;

  setUp(() {
    factory = FakeVideoFactory();
    controller = AppVideoController(source, factory: factory.call);
    addTearDown(controller.dispose);
  });

  test('starts initializing, becomes ready with duration', () async {
    expect(controller.value.status, AppVideoStatus.initializing);
    await controller.initialize();
    expect(controller.value.status, AppVideoStatus.ready);
    expect(controller.value.duration, const Duration(seconds: 60));
    expect(controller.value.aspectRatio, 16 / 9);
    expect(factory.last.calls, contains('setLooping:false'));
  });

  test('stays initializing while the backend loads', () async {
    final hold = Completer<void>();
    final held = FakeVideoFactory(holdInit: hold);
    final c = AppVideoController(source, factory: held.call);
    addTearDown(c.dispose);
    final init = c.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(c.value.status, AppVideoStatus.initializing);
    hold.complete();
    await init;
    expect(c.value.status, AppVideoStatus.ready);
  });

  test('play, pause and toggle move through playing and paused', () async {
    await controller.initialize();
    await controller.play();
    expect(controller.value.status, AppVideoStatus.playing);
    await controller.pause();
    expect(controller.value.status, AppVideoStatus.paused);
    await controller.togglePlay();
    expect(controller.value.status, AppVideoStatus.playing);
    await controller.togglePlay();
    expect(controller.value.status, AppVideoStatus.paused);
  });

  test('play before initialization does nothing', () async {
    await controller.play();
    expect(controller.value.status, AppVideoStatus.initializing);
  });

  test('buffering is reported once playback has started', () async {
    await controller.initialize();
    await controller.play();
    factory.last.emit(isBuffering: true);
    expect(controller.value.status, AppVideoStatus.buffering);
    factory.last.emit(isBuffering: false);
    expect(controller.value.status, AppVideoStatus.playing);
  });

  test('exposes buffered, position, volume and speed', () async {
    await controller.initialize();
    factory.last.emit(
      position: const Duration(seconds: 5),
      buffered: const Duration(seconds: 20),
    );
    expect(controller.value.position, const Duration(seconds: 5));
    expect(controller.value.buffered, const Duration(seconds: 20));
    await controller.setSpeed(1.5);
    expect(controller.value.speed, 1.5);
    expect(factory.last.calls, contains('setSpeed:1.5'));
  });

  test('seekTo clamps to 0..duration and seekBy is relative', () async {
    await controller.initialize();
    await controller.seekTo(const Duration(seconds: 500));
    expect(controller.value.position, const Duration(seconds: 60));
    await controller.seekTo(const Duration(seconds: -5));
    expect(controller.value.position, Duration.zero);
    await controller.seekTo(const Duration(seconds: 30));
    await controller.seekBy(appVideoSeekStep);
    expect(controller.value.position, const Duration(seconds: 40));
    await controller.seekBy(-appVideoSeekStep);
    expect(controller.value.position, const Duration(seconds: 30));
  });

  test('mute sets volume 0 and unmute restores the previous volume', () async {
    await controller.initialize();
    factory.last.emit(volume: 0.6);
    await controller.setMuted(true);
    expect(controller.value.isMuted, isTrue);
    await controller.toggleMute();
    expect(controller.value.isMuted, isFalse);
    expect(controller.value.volume, 0.6);
  });

  test('ended fires onEnded once; play from ended restarts', () async {
    var ended = 0;
    controller.onEnded = () => ended++;
    await controller.initialize();
    await controller.play();
    factory.last.emit(position: const Duration(seconds: 60), isPlaying: false);
    expect(controller.value.status, AppVideoStatus.ended);
    expect(ended, 1);
    factory.last.emit(buffered: const Duration(seconds: 60));
    expect(ended, 1);

    await controller.play();
    expect(factory.last.calls, contains('seekTo:0'));
    expect(controller.value.status, AppVideoStatus.playing);
  });

  test('looping videos never report ended', () async {
    final loop = FakeVideoFactory();
    final c = AppVideoController(source, factory: loop.call, looping: true);
    addTearDown(c.dispose);
    await c.initialize();
    await c.play();
    loop.last.emit(position: const Duration(seconds: 60));
    expect(c.value.status, AppVideoStatus.playing);
    expect(loop.last.calls, contains('setLooping:true'));
  });

  test('init failure gives error state; retry recovers', () async {
    final failing = FakeVideoFactory(failFirst: true);
    final c = AppVideoController(source, factory: failing.call);
    addTearDown(c.dispose);
    await c.initialize();
    expect(c.value.status, AppVideoStatus.error);
    expect(c.value.errorMessage, contains('init failed'));

    await c.retry();
    expect(c.value.status, AppVideoStatus.ready);
    expect(failing.created, hasLength(2));
    expect(failing.created.first.disposed, isTrue);
  });

  test('engine error after start moves to error', () async {
    await controller.initialize();
    factory.last.emit(errorDescription: 'decoder died');
    expect(controller.value.status, AppVideoStatus.error);
    expect(controller.value.errorMessage, 'decoder died');
  });

  test('dispose releases the backend and ignores later calls', () async {
    await controller.initialize();
    final backend = factory.last;
    controller.dispose();
    expect(backend.disposed, isTrue);
    controller.dispose();
    await controller.play();
    await controller.seekTo(Duration.zero);
  });

  test('dispose during initialization does not throw', () async {
    final hold = Completer<void>();
    final held = FakeVideoFactory(holdInit: hold);
    final c = AppVideoController(source, factory: held.call);
    final init = c.initialize();
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    hold.complete();
    await init;
    expect(held.last.disposed, isTrue);
  });

  test('sources compare by value', () {
    expect(
      const AppVideoSource.network('a'),
      const AppVideoSource.network('a'),
    );
    expect(
      const AppVideoSource.asset('a'),
      isNot(const AppVideoSource.file('a')),
    );
    expect(
      const AppVideoSource.file('a').hashCode,
      const AppVideoSource.file('a').hashCode,
    );
  });
}
