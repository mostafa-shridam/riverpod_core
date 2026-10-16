import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_samples.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';

/// `AppVideoPlayer` with an MP4 and, on demand, an HLS stream.
class MediaSection extends StatefulWidget {
  const MediaSection({
    super.key,
    this.backendFactory = createVideoPlayerBackend,
  });

  /// Playback engine factory; tests pass a fake so no platform channel runs.
  final AppVideoBackendFactory backendFactory;

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection> {
  // The HLS player only mounts on request, so opening the gallery does not
  // start two network streams.
  bool _hlsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.tokens.spacing;
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-media'),
      title: 'showcase.sections.media'.tr(),
      children: [
        Text('showcase.media.mp4'.tr(), style: theme.textTheme.labelLarge),
        AppVideoPlayer(
          source: const AppVideoSource.network(showcaseVideoUrl),
          backendFactory: widget.backendFactory,
        ),
        Text('showcase.media.hls'.tr(), style: theme.textTheme.labelLarge),
        if (_hlsLoaded)
          AppVideoPlayer(
            source: const AppVideoSource.network(showcaseHlsUrl),
            backendFactory: widget.backendFactory,
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              key: const ValueKey('load-hls'),
              label: 'showcase.media.loadHls'.tr(),
              icon: Icons.play_circle_outline_rounded,
              variant: AppButtonVariant.tonal,
              onPressed: () => setState(() => _hlsLoaded = true),
            ),
          ),
        Padding(
          padding: EdgeInsetsDirectional.only(top: spacing.xs),
          child: Text(
            'showcase.media.note'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
