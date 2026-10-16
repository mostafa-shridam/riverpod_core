import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_labels.dart';
import 'package:riverpod_core/core/design_system/widgets/media/media_strings.dart';

/// Brief rewind/forward badge after a double-tap.
class AppVideoSeekFlash extends StatelessWidget {
  const AppVideoSeekFlash({
    super.key,
    required this.forward,
    required this.labels,
  });

  final bool forward;
  final AppVideoLabels labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    // Physical side, matching the double-tap halves (timeline is LTR).
    return Align(
      alignment: Alignment(forward ? 0.6 : -0.6, 0),
      child: Semantics(
        label: forward
            ? labels.forward ?? dsMediaForwardKey.tr()
            : labels.rewind ?? dsMediaRewindKey.tr(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.scrim.withValues(alpha: 0.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.md),
            child: Icon(
              forward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
              size: tokens.sizes.iconLg,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Error message with a retry button, centered over the video.
class AppVideoErrorPanel extends StatelessWidget {
  const AppVideoErrorPanel({
    super.key,
    required this.labels,
    required this.onRetry,
  });

  final AppVideoLabels labels;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: tokens.sizes.iconLg,
              color: scheme.error,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              labels.error ?? dsMediaErrorKey.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
            ),
            SizedBox(height: tokens.spacing.md),
            AppButton(
              label: labels.retry ?? dsMediaRetryKey.tr(),
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.tonal,
              size: AppButtonSize.sm,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
