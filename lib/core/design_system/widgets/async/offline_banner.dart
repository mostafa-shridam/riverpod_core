import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_motion.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Subtle full-width strip that explains why the data on screen may be old.
///
/// - Offline: warning colors, "You're offline" (+ "showing saved data").
/// - Stale while online: quiet surface colors, "Last updated {time}".
/// - Otherwise it collapses to nothing.
///
/// By default it follows `connectivityProvider`, so it can sit in a scaffold
/// banner slot with no arguments. Pass [isOffline] to drive it by hand.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    super.key,
    this.isOffline,
    this.isStale = false,
    this.lastUpdated,
  });

  /// Forces the offline look; null follows the connectivity provider.
  final bool? isOffline;

  /// Data on screen comes from a cache or a failed revalidation.
  final bool isStale;

  /// When the shown data was fetched.
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline =
        isOffline ??
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;
    final visible = offline || isStale;
    return AnimatedSize(
      duration: motionDuration(context, context.tokens.durations.normal),
      curve: context.tokens.durations.standardCurve,
      alignment: AlignmentDirectional.topStart,
      child: visible
          ? _Strip(
              offline: offline,
              savedData: isStale || lastUpdated != null,
              lastUpdated: lastUpdated,
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({
    required this.offline,
    required this.savedData,
    required this.lastUpdated,
  });

  final bool offline;
  final bool savedData;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warning = AppStatusType.warning.colorsOf(context);
    final background = offline
        ? warning.container
        : scheme.surfaceContainerHigh;
    final foreground = offline ? warning.onContainer : scheme.onSurfaceVariant;
    final title = offline
        ? (savedData
                  ? LocaleKeys.ds_async_bannerOfflineSaved
                  : LocaleKeys.ds_async_bannerOffline)
              .tr()
        : (lastUpdated == null
              ? LocaleKeys.ds_async_bannerStale.tr()
              : LocaleKeys.ds_async_bannerLastUpdated.tr(
                  args: [_format(context)],
                ));
    final subtitle = offline && lastUpdated != null
        ? LocaleKeys.ds_async_bannerLastUpdated.tr(args: [_format(context)])
        : null;
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: background,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                offline ? Icons.wifi_off_rounded : Icons.history_rounded,
                size: tokens.sizes.iconSm,
                color: foreground,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(BuildContext context) => DateFormat.yMMMd(
    context.locale.languageCode,
  ).add_jm().format(lastUpdated!);
}
