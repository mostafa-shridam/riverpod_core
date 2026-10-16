import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controls.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_labels.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

/// Fallback shape until the video reports its own.
const _defaultAspectRatio = 16 / 9;

/// The one video primitive: a rounded player with tokenized overlay controls
/// (play/pause, seek bar with buffered segment, time, mute, speed,
/// fullscreen, double-tap seek, auto-hide). Features never use
/// `video_player` directly (D-027).
///
/// Pass [controller] to own the playback yourself (for example from a
/// Riverpod provider); the widget then never disposes it. Without one, the
/// widget creates a controller from [source] and disposes it. Playback
/// pauses when the app goes to the background.
class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    super.key,
    this.source,
    this.controller,
    this.autoPlay = false,
    this.looping = false,
    this.aspectRatio,
    this.placeholder,
    this.onEnded,
    this.labels = const AppVideoLabels(),
    this.backendFactory = createVideoPlayerBackend,
  }) : assert(
         (source == null) != (controller == null),
         'Pass exactly one of source or controller',
       );

  final AppVideoSource? source;
  final AppVideoController? controller;

  /// Starts playing as soon as the video is ready (own controller only).
  final bool autoPlay;
  final bool looping;

  /// Width / height of the player box. Defaults to the video's own ratio,
  /// or 16:9 until it is known.
  final double? aspectRatio;

  /// Shown (poster, thumbnail, skeleton) until playback first starts.
  final Widget? placeholder;
  final VoidCallback? onEnded;
  final AppVideoLabels labels;

  /// Playback engine factory; tests pass a fake so no platform channel runs.
  final AppVideoBackendFactory backendFactory;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer>
    with WidgetsBindingObserver {
  AppVideoController? _own;

  AppVideoController get _c => widget.controller ?? _own!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.controller == null) _createOwn();
  }

  void _createOwn() {
    final c = AppVideoController(
      widget.source!,
      factory: widget.backendFactory,
      looping: widget.looping,
      onEnded: () => widget.onEnded?.call(),
    );
    _own = c;
    unawaited(_start(c));
  }

  Future<void> _start(AppVideoController c) async {
    await c.initialize();
    if (widget.autoPlay && identical(c, _own)) await c.play();
  }

  @override
  void didUpdateWidget(AppVideoPlayer old) {
    super.didUpdateWidget(old);
    final sourceChanged =
        widget.source != old.source || widget.looping != old.looping;
    if (widget.controller != null) {
      _own?.dispose();
      _own = null;
    } else if (_own == null || sourceChanged) {
      _own?.dispose();
      _createOwn();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_c.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _own?.dispose();
    super.dispose();
  }

  Future<void> _openFullscreen() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final fade = context.tokens.durations.normal;
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    try {
      await navigator.push<void>(
        PageRouteBuilder<void>(
          opaque: true,
          transitionDuration: fade,
          reverseTransitionDuration: fade,
          pageBuilder: (routeContext, _, _) => _FullscreenPage(
            controller: _c,
            labels: widget.labels,
            placeholder: widget.placeholder,
          ),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } finally {
      unawaited(SystemChrome.setPreferredOrientations(const []));
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<AppVideoState>(
      valueListenable: _c,
      builder: (context, state, child) => AspectRatio(
        aspectRatio:
            widget.aspectRatio ?? state.aspectRatio ?? _defaultAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          child: ColoredBox(color: scheme.scrim, child: child),
        ),
      ),
      child: AppVideoSurface(
        controller: _c,
        labels: widget.labels,
        placeholder: widget.placeholder,
        isFullscreen: false,
        onToggleFullscreen: () => unawaited(_openFullscreen()),
      ),
    );
  }
}

/// Video picture + placeholder + controls, shared by the inline player and
/// the fullscreen route.
class AppVideoSurface extends StatelessWidget {
  const AppVideoSurface({
    super.key,
    required this.controller,
    required this.labels,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    this.placeholder,
  });

  final AppVideoController controller;
  final AppVideoLabels labels;
  final Widget? placeholder;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder<AppVideoState>(
          valueListenable: controller,
          builder: (context, state, _) {
            final showPlaceholder =
                placeholder != null &&
                (state.status == AppVideoStatus.initializing ||
                    state.status == AppVideoStatus.ready ||
                    state.status == AppVideoStatus.error);
            return Stack(
              fit: StackFit.expand,
              children: [
                if (state.isReady)
                  Center(
                    child: AspectRatio(
                      aspectRatio: state.aspectRatio ?? _defaultAspectRatio,
                      child: controller.buildView(context),
                    ),
                  ),
                if (showPlaceholder) placeholder!,
              ],
            );
          },
        ),
        AppVideoControls(
          controller: controller,
          labels: labels,
          isFullscreen: isFullscreen,
          onToggleFullscreen: onToggleFullscreen,
        ),
      ],
    );
  }
}

class _FullscreenPage extends StatelessWidget {
  const _FullscreenPage({
    required this.controller,
    required this.labels,
    this.placeholder,
  });

  final AppVideoController controller;
  final AppVideoLabels labels;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.scrim,
      body: AppVideoSurface(
        controller: controller,
        labels: labels,
        placeholder: placeholder,
        isFullscreen: true,
        onToggleFullscreen: () => Navigator.of(context).pop(),
      ),
    );
  }
}
