import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_switch.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Security settings: the app lock switch. The switch is disabled, with an
/// explanation, when the device has no biometrics and no passcode.
class SecuritySettingsPage extends ConsumerWidget {
  static const routeName = '/security-settings';

  const SecuritySettingsPage({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    final result = await ref
        .read(appLockControllerProvider.notifier)
        .setEnabled(enabled: enabled);
    if (!context.mounted) return;
    final message = switch (result) {
      BiometricResult.success => null,
      BiometricResult.cancelled => LocaleKeys.security_settings_cancelled.tr(),
      BiometricResult.failed => LocaleKeys.security_settings_failed.tr(),
      BiometricResult.lockedOut => LocaleKeys.security_settings_lockedOut.tr(),
      BiometricResult.notAvailable =>
        LocaleKeys.security_settings_unavailable.tr(),
    };
    if (message == null) return;
    showAppSnackbar(context, message: message, type: AppStatusType.warning);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(biometricAvailableProvider);
    final lock = ref.watch(appLockControllerProvider);
    final tokens = context.tokens;
    return AppScaffold(
      key: const ValueKey('security-settings-page'),
      appBar: AppAppBar(title: LocaleKeys.security_settings_title.tr()),
      body: AsyncValueView<bool>(
        value: available,
        onRetry: () => ref.invalidate(biometricAvailableProvider),
        builder: (context, isAvailable) => ListView(
          padding: EdgeInsetsDirectional.symmetric(vertical: tokens.spacing.lg),
          children: [
            AppSwitch(
              value: lock.enabled,
              label: LocaleKeys.security_settings_appLock.tr(),
              subtitle: LocaleKeys.security_settings_appLockSubtitle.tr(),
              enabled: isAvailable && !lock.unlocking,
              onChanged: isAvailable
                  ? (value) => _toggle(context, ref, enabled: value)
                  : null,
            ),
            if (!isAvailable)
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.spacing.lg,
                ),
                child: Text(
                  LocaleKeys.security_settings_unavailable.tr(),
                  key: const ValueKey('security-unavailable'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
