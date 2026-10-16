import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/progress/app_progress_indicator.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_labels.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_overlays.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_seek_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/media/media_strings.dart';

/// Formats [d] as `m:ss` or `h:mm:ss` with the digits of [locale].
String formatVideoDuration(Duration d, String locale) {
  final two = NumberFormat('00', locale);
  final one = NumberFormat('0', locale);
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0
      ? '${one.format(h)}:${two.format(m)}:${two.format(s)}'
      : '${one.format(m)}:${two.format(s)}';
}

/// Overlay controls of the video player. The video chrome is always drawn
/// with the dark theme (white-on-scrim), whatever the app mode, like every
/// media player: the picture decides the background, not the app theme.
class AppVideoControls extends StatefulWidget {
  const AppVideoControls({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    this.labels = const AppVideoLabels(),
  });

  final AppVideoController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final AppVideoLabels labels;

  @override
  State<AppVideoControls> createState() => _AppVideoControlsState();
}

class _AppVideoControlsState extends State<AppVideoControls> {
  static final ThemeData _chromeTheme = buildDarkTheme();

  Timer? _hideTimer;
  Timer? _flashTimer;
  bool _visible = true;
  bool _holding = false;
  int _flash = 0;
  double _doubleTapDx = 0;
  AppVideoStatus _status = AppVideoStatus.initializing;

  AppVideoController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _status = _c.value.status;
    _c.addListener(_onState);
    if (_status == AppVideoStatus.playing) _restartTimer();
  }

  @override
  void dispose() {
    _c.removeListener(_onState);
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _onState() {
    final next = _c.value.status;
    if (next == _status) return;
    final wasPlaying = _status == AppVideoStatus.playing;
    _status = next;
    if (next == AppVideoStatus.playing) {
      _restartTimer();
    } else if (wasPlaying) {
      _hideTimer?.cancel();
      if (mounted) setState(() => _visible = true);
    }
  }

  void _restartTimer() {
    _hideTimer?.cancel();
    if (_c.value.status != AppVideoStatus.playing || _holding) return;
    _hideTimer = Timer(appVideoAutoHideDelay, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _show() {
    if (!_visible) setState(() => _visible = true);
    _restartTimer();
  }

  void _onTap() {
    if (_visible && _c.value.status == AppVideoStatus.playing) {
      _hideTimer?.cancel();
      setState(() => _visible = false);
    } else {
      _show();
    }
  }

  void _hold(bool holding) {
    _holding = holding;
    if (holding) {
      _hideTimer?.cancel();
    } else {
      _restartTimer();
    }
  }

  void _doubleTapSeek(double width) {
    // Physical halves, not start/end: the timeline is LTR (see the seek bar).
    final forward = _doubleTapDx > width / 2;
    unawaited(_c.seekBy(forward ? appVideoSeekStep : -appVideoSeekStep));
    _flashTimer?.cancel();
    setState(() => _flash = forward ? 1 : -1);
    _flashTimer = Timer(context.tokens.durations.slow, () {
      if (mounted) setState(() => _flash = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Theme(
      data: _chromeTheme,
      child: ValueListenableBuilder<AppVideoState>(
        valueListenable: _c,
        builder: (context, state, _) {
          final tokens = context.tokens;
          final show =
              _visible || _holding || state.status != AppVideoStatus.playing;
          final busy =
              state.status == AppVideoStatus.initializing ||
              state.status == AppVideoStatus.buffering;
          if (state.status == AppVideoStatus.error) {
            return AppVideoErrorPanel(
              labels: widget.labels,
              onRetry: () => unawaited(_c.retry()),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) => Stack(
              fit: StackFit.expand,
              children: [
                // Gesture layer UNDER the chrome: a double-tap recognizer
                // above the buttons would delay every button tap by the
                // double-tap timeout.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onTap,
                  onDoubleTapDown: (d) => _doubleTapDx = d.localPosition.dx,
                  onDoubleTap: () => _doubleTapSeek(constraints.maxWidth),
                ),
                AnimatedOpacity(
                  opacity: show ? 1 : 0,
                  duration: tokens.durations.normal,
                  curve: tokens.durations.standardCurve,
                  child: IgnorePointer(
                    ignoring: !show,
                    child: _Chrome(
                      state: state,
                      locale: locale,
                      labels: widget.labels,
                      isFullscreen: widget.isFullscreen,
                      onToggleFullscreen: widget.onToggleFullscreen,
                      controller: _c,
                      showCenter: !busy,
                      onInteraction: _show,
                      onHold: _hold,
                    ),
                  ),
                ),
                if (busy)
                  IgnorePointer(
                    child: Center(
                      child: AppProgressIndicator(
                        size: AppProgressSize.lg,
                        color: Theme.of(context).colorScheme.onSurface,
                        semanticLabel:
                            widget.labels.buffering ?? dsMediaBufferingKey.tr(),
                      ),
                    ),
                  ),
                if (_flash != 0)
                  IgnorePointer(
                    child: AppVideoSeekFlash(
                      forward: _flash > 0,
                      labels: widget.labels,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.state,
    required this.locale,
    required this.labels,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.controller,
    required this.showCenter,
    required this.onInteraction,
    required this.onHold,
  });

  final AppVideoState state;
  final String locale;
  final AppVideoLabels labels;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final AppVideoController controller;
  final bool showCenter;
  final VoidCallback onInteraction;
  final ValueChanged<bool> onHold;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ended = state.status == AppVideoStatus.ended;
    final playing = state.status == AppVideoStatus.playing;
    final speedFormat = NumberFormat('0.#', locale);
    final elapsed = formatVideoDuration(state.position, locale);
    final total = formatVideoDuration(state.duration, locale);

    String stepped(Duration delta) {
      final target = state.position + delta;
      final clamped = target.isNegative
          ? Duration.zero
          : (target > state.duration ? state.duration : target);
      return formatVideoDuration(clamped, locale);
    }

    void act(Future<void> Function() fn) {
      onInteraction();
      unawaited(fn());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.scrim.withValues(alpha: 0.25),
                  scheme.scrim.withValues(alpha: 0),
                  scheme.scrim.withValues(alpha: 0.7),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
        ),
        if (showCenter)
          Center(
            child: AppIconButton(
              icon: ended
                  ? Icons.replay_rounded
                  : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              tooltip: ended
                  ? labels.replay ?? dsMediaReplayKey.tr()
                  : (playing
                        ? labels.pause ?? dsMediaPauseKey.tr()
                        : labels.play ?? dsMediaPlayKey.tr()),
              variant: AppIconButtonVariant.filled,
              size: AppButtonSize.lg,
              onPressed: () => act(controller.togglePlay),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: spacing.sm,
              end: spacing.sm,
              bottom: spacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppVideoSeekBar(
                  position: state.position,
                  buffered: state.buffered,
                  duration: state.duration,
                  semanticLabel: labels.seekBar ?? dsMediaSeekBarKey.tr(),
                  semanticValue: '$elapsed / $total',
                  semanticIncreasedValue:
                      '${stepped(appVideoSeekStep)} / $total',
                  semanticDecreasedValue:
                      '${stepped(-appVideoSeekStep)} / $total',
                  onDragChanged: onHold,
                  onSeek: (p) => act(() => controller.seekTo(p)),
                  onSeekStep: (fwd) => act(
                    () => controller.seekBy(
                      fwd ? appVideoSeekStep : -appVideoSeekStep,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: spacing.sm),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '$elapsed / $total',
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: state.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      tooltip: state.isMuted
                          ? labels.unmute ?? dsMediaUnmuteKey.tr()
                          : labels.mute ?? dsMediaMuteKey.tr(),
                      onPressed: () => act(controller.toggleMute),
                    ),
                    PopupMenuButton<double>(
                      tooltip: labels.speed ?? dsMediaSpeedKey.tr(),
                      initialValue: state.speed,
                      onOpened: () => onHold(true),
                      onCanceled: () => onHold(false),
                      onSelected: (s) {
                        onHold(false);
                        act(() => controller.setSpeed(s));
                      },
                      itemBuilder: (_) => [
                        for (final s in appVideoSpeeds)
                          PopupMenuItem<double>(
                            value: s,
                            child: Text('${speedFormat.format(s)}×'),
                          ),
                      ],
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: tokens.sizes.minTouchTarget,
                          minHeight: tokens.sizes.minTouchTarget,
                        ),
                        child: Center(
                          child: Text(
                            '${speedFormat.format(state.speed)}×',
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      tooltip: isFullscreen
                          ? labels.exitFullscreen ??
                                dsMediaExitFullscreenKey.tr()
                          : labels.fullscreen ?? dsMediaFullscreenKey.tr(),
                      onPressed: () {
                        onInteraction();
                        onToggleFullscreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
