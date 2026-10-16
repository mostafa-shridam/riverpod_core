import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

/// In-memory playback engine: records every call, never touches a platform
/// channel. Tests drive its state with [emit].
class FakeVideoBackend extends ChangeNotifier implements AppVideoBackend {
  FakeVideoBackend(
    this.source, {
    this.failInit = false,
    this.holdInit,
    this.duration = const Duration(seconds: 60),
  });

  final AppVideoSource source;
  final bool failInit;

  /// While non-null and incomplete, `initialize` waits (state: initializing).
  final Completer<void>? holdInit;
  final Duration duration;

  final List<String> calls = [];
  bool disposed = false;
  AppVideoBackendValue _value = const AppVideoBackendValue();

  @override
  AppVideoBackendValue get value => _value;

  /// Replaces the reported state and notifies like a real engine.
  void emit({
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? buffered,
    double? volume,
    double? speed,
    String? errorDescription,
  }) {
    _value = AppVideoBackendValue(
      isInitialized: isInitialized ?? _value.isInitialized,
      isPlaying: isPlaying ?? _value.isPlaying,
      isBuffering: isBuffering ?? _value.isBuffering,
      position: position ?? _value.position,
      duration: _value.duration,
      buffered: buffered ?? _value.buffered,
      volume: volume ?? _value.volume,
      speed: speed ?? _value.speed,
      aspectRatio: _value.aspectRatio,
      errorDescription: errorDescription ?? _value.errorDescription,
    );
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    calls.add('initialize');
    if (holdInit != null) await holdInit!.future;
    if (failInit) throw StateError('init failed');
    _value = AppVideoBackendValue(
      isInitialized: true,
      duration: duration,
      aspectRatio: 16 / 9,
    );
    notifyListeners();
  }

  @override
  Future<void> play() async {
    calls.add('play');
    emit(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    emit(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    calls.add('seekTo:${position.inSeconds}');
    emit(position: position);
  }

  @override
  Future<void> setVolume(double volume) async {
    calls.add('setVolume:$volume');
    emit(volume: volume);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    calls.add('setSpeed:$speed');
    emit(speed: speed);
  }

  @override
  Future<void> setLooping(bool looping) async =>
      calls.add('setLooping:$looping');

  @override
  Widget buildView(BuildContext context) => const DecoratedBox(
    key: ValueKey('fake-video'),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF5B7DB1), Color(0xFFB07A5B)]),
    ),
  );

  @override
  Future<void> dispose() async {
    disposed = true;
    super.dispose();
  }
}

/// Factory that remembers every backend it created.
class FakeVideoFactory {
  FakeVideoFactory({this.failFirst = false, this.holdInit});

  final bool failFirst;
  final Completer<void>? holdInit;
  final List<FakeVideoBackend> created = [];

  FakeVideoBackend get last => created.last;

  AppVideoBackend call(AppVideoSource source) {
    final backend = FakeVideoBackend(
      source,
      failInit: failFirst && created.isEmpty,
      holdInit: holdInit,
    );
    created.add(backend);
    return backend;
  }
}
