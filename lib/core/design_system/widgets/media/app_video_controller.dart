import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

/// Seek distance of double-tap and the rewind/forward actions.
const appVideoSeekStep = Duration(seconds: 10);

/// Controls hide after this much idle time while the video plays.
const appVideoAutoHideDelay = Duration(seconds: 3);

/// Speeds offered by the speed menu.
const appVideoSpeeds = <double>[0.5, 1.0, 1.5, 2.0];

enum AppVideoStatus {
  initializing,
  ready,
  playing,
  paused,
  buffering,
  ended,
  error,
}

/// Immutable snapshot published by [AppVideoController].
@immutable
class AppVideoState {
  const AppVideoState({
    this.status = AppVideoStatus.initializing,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.aspectRatio,
    this.errorMessage,
  });

  final AppVideoStatus status;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final double volume;
  final double speed;
  final double? aspectRatio;
  final String? errorMessage;

  bool get isMuted => volume == 0;
  bool get isPlaying => status == AppVideoStatus.playing;
  bool get isReady =>
      status != AppVideoStatus.initializing && status != AppVideoStatus.error;

  AppVideoState copyWith({
    AppVideoStatus? status,
    double? speed,
    String? errorMessage,
  }) => AppVideoState(
    status: status ?? this.status,
    position: position,
    duration: duration,
    buffered: buffered,
    volume: volume,
    speed: speed ?? this.speed,
    aspectRatio: aspectRatio,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      other is AppVideoState &&
      other.status == status &&
      other.position == position &&
      other.duration == duration &&
      other.buffered == buffered &&
      other.volume == volume &&
      other.speed == speed &&
      other.aspectRatio == aspectRatio &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(
    status,
    position,
    duration,
    buffered,
    volume,
    speed,
    aspectRatio,
    errorMessage,
  );
}

/// Owns one playback backend and publishes [AppVideoState] as a
/// `ValueListenable`, so widgets use `ValueListenableBuilder` and a Riverpod
/// provider can expose it directly (`ref.onDispose(controller.dispose)`).
class AppVideoController extends ValueNotifier<AppVideoState> {
  AppVideoController(
    this.source, {
    AppVideoBackendFactory factory = createVideoPlayerBackend,
    this.looping = false,
    this.onEnded,
  }) : _factory = factory,
       super(const AppVideoState());

  final AppVideoSource source;
  final bool looping;

  /// Called once each time playback reaches the end (never when looping).
  VoidCallback? onEnded;

  final AppVideoBackendFactory _factory;
  AppVideoBackend? _backend;
  bool _disposed = false;
  bool _hasStarted = false;
  double _volumeBeforeMute = 1.0;

  /// The video surface once created; an empty box before that.
  Widget buildView(BuildContext context) =>
      _backend?.buildView(context) ?? const SizedBox.shrink();

  /// Creates the backend and starts loading. Safe to call again after an
  /// error (see [retry]).
  Future<void> initialize() async {
    final previous = _backend;
    _backend = null;
    _hasStarted = false;
    previous?.removeListener(_sync);
    await previous?.dispose();
    if (_disposed) return;
    value = AppVideoState(volume: value.volume, speed: value.speed);
    final backend = _factory(source);
    _backend = backend;
    backend.addListener(_sync);
    try {
      await backend.initialize();
      if (_disposed || _backend != backend) return;
      await backend.setLooping(looping);
      await backend.setVolume(value.volume);
      await backend.setPlaybackSpeed(value.speed);
      _sync();
    } on Object catch (e) {
      if (_disposed || _backend != backend) return;
      value = value.copyWith(
        status: AppVideoStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> retry() => initialize();

  Future<void> play() async {
    final backend = _backend;
    if (backend == null || !value.isReady) return;
    _hasStarted = true;
    if (value.status == AppVideoStatus.ended) {
      await backend.seekTo(Duration.zero);
    }
    await backend.play();
  }

  Future<void> pause() async => _backend?.pause();

  Future<void> togglePlay() => value.isPlaying ? pause() : play();

  Future<void> seekTo(Duration position) async {
    final backend = _backend;
    if (backend == null || !value.isReady) return;
    final max = value.duration;
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > max ? max : position);
    await backend.seekTo(clamped);
  }

  Future<void> seekBy(Duration delta) => seekTo(value.position + delta);

  Future<void> setSpeed(double speed) async {
    await _backend?.setPlaybackSpeed(speed);
  }

  Future<void> setMuted(bool muted) async {
    if (muted == value.isMuted) return;
    if (muted) _volumeBeforeMute = value.volume;
    await _backend?.setVolume(muted ? 0 : _volumeBeforeMute);
  }

  Future<void> toggleMute() => setMuted(!value.isMuted);

  void _sync() {
    final backend = _backend;
    if (_disposed || backend == null) return;
    final b = backend.value;
    final AppVideoStatus status;
    if (b.errorDescription != null) {
      status = AppVideoStatus.error;
    } else if (!b.isInitialized) {
      status = AppVideoStatus.initializing;
    } else if (b.duration > Duration.zero &&
        b.position >= b.duration &&
        !b.isPlaying &&
        !looping) {
      status = AppVideoStatus.ended;
    } else if (b.isBuffering && _hasStarted) {
      status = AppVideoStatus.buffering;
    } else if (b.isPlaying) {
      status = AppVideoStatus.playing;
    } else {
      status = _hasStarted ? AppVideoStatus.paused : AppVideoStatus.ready;
    }
    final wasEnded = value.status == AppVideoStatus.ended;
    value = AppVideoState(
      status: status,
      position: b.position,
      duration: b.duration,
      buffered: b.buffered,
      volume: b.volume,
      speed: b.speed,
      aspectRatio: b.aspectRatio,
      errorMessage: b.errorDescription,
    );
    if (status == AppVideoStatus.ended && !wasEnded) onEnded?.call();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final backend = _backend;
    _backend = null;
    backend?.removeListener(_sync);
    unawaited(backend?.dispose());
    super.dispose();
  }
}
