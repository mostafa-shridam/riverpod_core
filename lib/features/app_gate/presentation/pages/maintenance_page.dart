import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Shown instead of the app while the server is in maintenance. The server's
/// message wins over the default copy when it sends one.
class MaintenancePage extends ConsumerWidget {
  static const routeName = '/maintenance';

  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final message = ref.watch(currentRemoteConfigProvider).maintenance.message;

    return Scaffold(
      key: const ValueKey('maintenance-page'),
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
                      Icons.build_circle_rounded,
                      size: tokens.spacing.xxxl * 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  Text(
                    LocaleKeys.app_gate_maintenance_title.tr(),
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing.md),
                  Text(
                    message ?? LocaleKeys.app_gate_maintenance_body.tr(),
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacing.xl),
                  AppButton(
                    label: LocaleKeys.errors_retry.tr(),
                    fullWidth: true,
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
