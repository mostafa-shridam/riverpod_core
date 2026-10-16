import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Seek bar with a buffered segment, a played segment and a thumb.
///
/// It is always laid out left-to-right, also in RTL: a video timeline is not
/// text, and mirroring it would make "forward" point to the start side,
/// which contradicts the double-tap zones and the media-player convention.
class AppVideoSeekBar extends StatefulWidget {
  const AppVideoSeekBar({
    super.key,
    required this.position,
    required this.buffered,
    required this.duration,
    required this.onSeek,
    required this.semanticLabel,
    required this.semanticValue,
    required this.semanticIncreasedValue,
    required this.semanticDecreasedValue,
    required this.onSeekStep,
    this.onDragChanged,
  });

  final Duration position;
  final Duration buffered;
  final Duration duration;

  /// Called once when the user releases the thumb or taps the bar.
  final ValueChanged<Duration> onSeek;

  /// Keyboard/screen-reader increase (true) and decrease (false).
  final ValueChanged<bool> onSeekStep;
  final String semanticLabel;
  final String semanticValue;

  /// Values announced after a screen-reader step forward / back.
  final String semanticIncreasedValue;
  final String semanticDecreasedValue;

  /// True while the thumb is held (controls must not auto-hide).
  final ValueChanged<bool>? onDragChanged;

  @override
  State<AppVideoSeekBar> createState() => _AppVideoSeekBarState();
}

class _AppVideoSeekBarState extends State<AppVideoSeekBar> {
  double? _dragFraction;

  double _fractionAt(double dx, double width) =>
      width <= 0 ? 0 : (dx / width).clamp(0.0, 1.0);

  void _end(double fraction) {
    widget.onSeek(widget.duration * fraction);
    setState(() => _dragFraction = null);
    widget.onDragChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final total = widget.duration.inMilliseconds;
    final played =
        _dragFraction ??
        (total == 0
            ? 0.0
            : (widget.position.inMilliseconds / total).clamp(0.0, 1.0));
    final buffered = total == 0
        ? 0.0
        : (widget.buffered.inMilliseconds / total).clamp(0.0, 1.0);
    final dragging = _dragFraction != null;

    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: widget.semanticValue,
      increasedValue: widget.semanticIncreasedValue,
      decreasedValue: widget.semanticDecreasedValue,
      onIncrease: () => widget.onSeekStep(true),
      onDecrease: () => widget.onSeekStep(false),
      child: ExcludeSemantics(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => widget.onSeek(
                  widget.duration * _fractionAt(d.localPosition.dx, width),
                ),
                onHorizontalDragStart: (d) {
                  setState(
                    () =>
                        _dragFraction = _fractionAt(d.localPosition.dx, width),
                  );
                  widget.onDragChanged?.call(true);
                },
                onHorizontalDragUpdate: (d) => setState(
                  () => _dragFraction = _fractionAt(d.localPosition.dx, width),
                ),
                onHorizontalDragEnd: (_) => _end(_dragFraction ?? played),
                onHorizontalDragCancel: () {
                  if (_dragFraction != null) {
                    setState(() => _dragFraction = null);
                    widget.onDragChanged?.call(false);
                  }
                },
                child: SizedBox(
                  height: tokens.sizes.minTouchTarget,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SeekBarPainter(
                      played: played,
                      buffered: buffered,
                      trackHeight: tokens.spacing.xs,
                      thumbRadius: dragging
                          ? tokens.spacing.sm + tokens.spacing.xs
                          : tokens.spacing.sm,
                      trackColor: scheme.onSurface.withValues(alpha: 0.24),
                      bufferedColor: scheme.onSurface.withValues(alpha: 0.5),
                      playedColor: scheme.primary,
                      radius: tokens.radius.full,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SeekBarPainter extends CustomPainter {
  const _SeekBarPainter({
    required this.played,
    required this.buffered,
    required this.trackHeight,
    required this.thumbRadius,
    required this.trackColor,
    required this.bufferedColor,
    required this.playedColor,
    required this.radius,
  });

  final double played;
  final double buffered;
  final double trackHeight;
  final double thumbRadius;
  final Color trackColor;
  final Color bufferedColor;
  final Color playedColor;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by the thumb radius so the thumb never clips at the ends.
    final left = thumbRadius;
    final span = size.width - 2 * thumbRadius;
    final cy = size.height / 2;
    RRect segment(double fraction) => RRect.fromLTRBR(
      left,
      cy - trackHeight / 2,
      left + span * fraction,
      cy + trackHeight / 2,
      Radius.circular(radius),
    );
    canvas
      ..drawRRect(segment(1), Paint()..color = trackColor)
      ..drawRRect(segment(buffered), Paint()..color = bufferedColor)
      ..drawRRect(segment(played), Paint()..color = playedColor)
      ..drawCircle(
        Offset(left + span * played, cy),
        thumbRadius,
        Paint()..color = playedColor,
      );
  }

  @override
  bool shouldRepaint(_SeekBarPainter old) =>
      old.played != played ||
      old.buffered != buffered ||
      old.playedColor != playedColor ||
      old.thumbRadius != thumbRadius;
}
