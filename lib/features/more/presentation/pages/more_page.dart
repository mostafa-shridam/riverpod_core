import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Second tab of the app shell. Holds the settings entries and the sign-out
/// action until an app fills it with profile and more settings.
class MorePage extends ConsumerWidget {
  static const routeName = '/more';

  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const ValueKey('more-page'),
      body: SafeArea(
        child: Column(
          children: [
            AppListTile(
              key: const ValueKey('more-security'),
              leading: const Icon(Icons.lock_outline_rounded),
              title: Text(LocaleKeys.security_settings_title.tr()),
              showChevron: true,
              onTap: () => const SecuritySettingsRoute().push<void>(context),
            ),
            Expanded(
              child: Center(
                child: AppButton(
                  label: LocaleKeys.auth_logout.tr(),
                  variant: AppButtonVariant.destructive,
                  onPressed: () => ref
                      .read(sessionControllerProvider.notifier)
                      .logout(
                        remoteLogout: () =>
                            ref.read(authRepositoryProvider).logout(),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
