import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';
import 'package:riverpod_core/features/more/presentation/pages/about_page.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Second tab of the app shell: the About entry and the sign-out action until
/// an app fills it with settings and profile.
class MorePage extends ConsumerWidget {
  static const routeName = '/more';

  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;
    return Scaffold(
      key: const ValueKey('more-page'),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.all(spacing.lg),
          children: [
            AppListTile(
              key: const ValueKey('more-about-tile'),
              leading: const Icon(Icons.info_outline),
              title: Text(LocaleKeys.more_entry_about.tr()),
              subtitle: Text(LocaleKeys.more_entry_aboutHint.tr()),
              showChevron: true,
              onTap: () => context.push(AboutPage.routeName),
            ),
            SizedBox(height: spacing.xl),
            AppButton(
              label: LocaleKeys.auth_logout.tr(),
              variant: AppButtonVariant.destructive,
              fullWidth: true,
              onPressed: () => ref
                  .read(sessionControllerProvider.notifier)
                  .logout(
                    remoteLogout: () =>
                        ref.read(authRepositoryProvider).logout(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
