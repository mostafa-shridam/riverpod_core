import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';
import 'package:video_player/video_player.dart';

part 'app_video_backend.g.dart';

/// Raw playback facts reported by an [AppVideoBackend].
@immutable
class AppVideoBackendValue {
  const AppVideoBackendValue({
    this.isInitialized = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.aspectRatio,
    this.errorDescription,
  });

  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;

  /// End of the furthest buffered range.
  final Duration buffered;
  final double volume;
  final double speed;

  /// Width / height of the decoded video, when known.
  final double? aspectRatio;
  final String? errorDescription;
}

/// The thin seam between [AppVideoController] and a playback engine. The
/// default one wraps `video_player`; tests inject a fake, so no platform
/// channel is needed.
abstract interface class AppVideoBackend implements Listenable {
  AppVideoBackendValue get value;
  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setLooping(bool looping);
  Future<void> dispose();

  /// The video surface (no controls).
  Widget buildView(BuildContext context);
}

typedef AppVideoBackendFactory =
    AppVideoBackend Function(AppVideoSource source);

/// The playback engine the video pages use. Override with a fake in tests
/// and the integration flow; the default is `video_player`.
@Riverpod(keepAlive: true)
AppVideoBackendFactory videoBackendFactory(Ref ref) => createVideoPlayerBackend;

/// Default factory: `video_player`.
AppVideoBackend createVideoPlayerBackend(AppVideoSource source) =>
    _VideoPlayerBackend(switch (source) {
      AppVideoNetworkSource(:final url) => VideoPlayerController.networkUrl(
        Uri.parse(url),
      ),
      AppVideoAssetSource(:final path) => VideoPlayerController.asset(path),
      AppVideoFileSource(:final path) => VideoPlayerController.file(File(path)),
    });

class _VideoPlayerBackend extends ChangeNotifier implements AppVideoBackend {
  _VideoPlayerBackend(this._controller) {
    _controller.addListener(notifyListeners);
  }

  final VideoPlayerController _controller;

  @override
  AppVideoBackendValue get value {
    final v = _controller.value;
    return AppVideoBackendValue(
      isInitialized: v.isInitialized,
      isPlaying: v.isPlaying,
      isBuffering: v.isBuffering,
      position: v.position,
      duration: v.duration,
      buffered: v.buffered.isEmpty ? Duration.zero : v.buffered.last.end,
      volume: v.volume,
      speed: v.playbackSpeed,
      aspectRatio: v.isInitialized && v.aspectRatio > 0 ? v.aspectRatio : null,
      errorDescription: v.hasError ? v.errorDescription : null,
    );
  }

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  @override
  Future<void> setVolume(double volume) => _controller.setVolume(volume);

  @override
  Future<void> setPlaybackSpeed(double speed) =>
      _controller.setPlaybackSpeed(speed);

  @override
  Future<void> setLooping(bool looping) => _controller.setLooping(looping);

  @override
  Widget buildView(BuildContext context) => VideoPlayer(_controller);

  @override
  Future<void> dispose() async {
    _controller.removeListener(notifyListeners);
    await _controller.dispose();
    super.dispose();
  }
}
