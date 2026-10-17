import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/features/app_gate/providers/app_gate_providers.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Shown instead of the app when this build is older than the minimum
/// version. Only the store and a retry are offered.
class ForceUpdatePage extends ConsumerWidget {
  static const routeName = '/force-update';

  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final storeUrl = ref.watch(currentRemoteConfigProvider).storeUrl;

    return Scaffold(
      key: const ValueKey('force-update-page'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.spacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.system_update_rounded,
                      size: tokens.spacing.xxxl * 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  Text(
                    LocaleKeys.app_gate_forceUpdate_title.tr(),
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Text(
                    LocaleKeys.app_gate_forceUpdate_body.tr(),
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing.xl),
                  AppButton(
                    label: LocaleKeys.app_gate_forceUpdate_store.tr(),
                    fullWidth: true,
                    onPressed: storeUrl == null
                        ? null
                        : () => ref.read(storeOpenerProvider)(
                            Uri.parse(storeUrl),
                          ),
                  ),
                  AppButton(
                    label: LocaleKeys.errors_retry.tr(),
                    variant: AppButtonVariant.text,
                    onPressed: () => ref.invalidate(remoteConfigProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
