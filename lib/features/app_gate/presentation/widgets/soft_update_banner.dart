import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/features/app_gate/providers/app_gate_providers.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// A dismissible notice that a newer version exists. Shows only while
/// [softUpdateNoticeProvider] is true; "later" remembers that version.
class SoftUpdateBanner extends ConsumerWidget {
  const SoftUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(softUpdateNoticeProvider)) return const SizedBox.shrink();
    final tokens = context.tokens;
    final config = ref.watch(currentRemoteConfigProvider);
    final storeUrl = config.storeUrl;

    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.app_gate_update_banner.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            AppButton(
              label: LocaleKeys.app_gate_update_later.tr(),
              variant: AppButtonVariant.text,
              onPressed: () => ref
                  .read(dismissedUpdatesProvider.notifier)
                  .dismiss(config.latestVersion),
            ),
            if (storeUrl != null)
              AppButton(
                label: LocaleKeys.app_gate_update_action.tr(),
                onPressed: () =>
                    ref.read(storeOpenerProvider)(Uri.parse(storeUrl)),
              ),
          ],
        ),
      ),
    );
  }
}
