import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_badge.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_image.dart';
import 'package:riverpod_core/core/utils/formatting/app_formatters.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';

/// Thumbnail box of a video, 16:9, with the duration badge in the corner.
/// Without a thumbnail URL (or when it fails) a colored placeholder with a
/// play icon is painted, so the demo needs no image assets.
class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({super.key, required this.video, this.radius});

  final Video video;

  /// Corner radius; defaults to the token used by cards.
  final BorderRadiusGeometry? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final url = video.thumbnailUrl;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: radius ?? BorderRadius.circular(tokens.radius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null)
              _ThumbnailPlaceholder(seed: video.id)
            else
              AppImage(
                url,
                placeholderBuilder: (_) =>
                    _ThumbnailPlaceholder(seed: video.id),
                errorBuilder: (_) => _ThumbnailPlaceholder(seed: video.id),
              ),
            if (video.durationSeconds > 0)
              PositionedDirectional(
                end: tokens.spacing.sm,
                bottom: tokens.spacing.sm,
                child: AppBadge(
                  count: video.durationSeconds,
                  maxCount: video.durationSeconds,
                  formatter: (seconds) => formatVideoDuration(
                    context.formatters,
                    Duration(seconds: seconds),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `m:ss`, or `h:mm:ss` from one hour, with the app's digit policy.
String formatVideoDuration(AppFormatters formatters, Duration duration) {
  String two(int value) => formatters.number(value).padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${formatters.number(hours)}:${two(minutes)}:${two(seconds)}';
  }
  return '${formatters.number(minutes)}:${two(seconds)}';
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Stable per video, so a card keeps its color between rebuilds.
    final pick = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 3;
    final (background, foreground) = switch (pick) {
      0 => (scheme.primaryContainer, scheme.onPrimaryContainer),
      1 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _ => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    };
    return ColoredBox(
      color: background,
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: context.tokens.sizes.iconLg * 2,
          color: foreground,
        ),
      ),
    );
  }
}
