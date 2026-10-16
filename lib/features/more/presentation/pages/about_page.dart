import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/review/review_service.dart';
import 'package:riverpod_core/core/sharing/share_service.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// App name, version, build, licenses, and the share and rate actions. The
/// flavor row shows in dev and staging builds only.
class AboutPage extends ConsumerWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appConfigProvider.select((c) => c.flavor));
    return AppScaffold(
      key: const ValueKey('about-page'),
      appBar: AppAppBar(title: LocaleKeys.more_about_title.tr()),
      body: AsyncValueView<AppInfo>(
        value: ref.watch(appInfoProvider),
        onRetry: () => ref.invalidate(appInfoProvider),
        builder: (context, info) => _AboutContent(info: info, flavor: flavor),
      ),
    );
  }
}

class _AboutContent extends ConsumerWidget {
  const _AboutContent({required this.info, required this.flavor});

  final AppInfo info;
  final Flavor flavor;

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final shown = await ref
        .read(shareServiceProvider)
        .shareText(LocaleKeys.more_about_shareMessage.tr(args: [info.name]));
    if (!shown && context.mounted) _showFailure(context);
  }

  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final service = await ref.read(reviewServiceProvider.future);
    final opened = await service.openStoreListing();
    if (!opened && context.mounted) _showFailure(context);
  }

  void _showFailure(BuildContext context) => showAppSnackbar(
    context,
    message: LocaleKeys.more_about_actionFailed.tr(),
    type: AppStatusType.error,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;
    return ListView(
      padding: EdgeInsetsDirectional.only(top: spacing.lg, bottom: spacing.xl),
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.lg),
          child: Text(
            info.name,
            key: const ValueKey('about-name'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SizedBox(height: spacing.lg),
        AppListTile(
          title: Text(LocaleKeys.more_about_version.tr()),
          subtitle: Text(info.version, key: const ValueKey('about-version')),
        ),
        if (info.buildNumber.isNotEmpty)
          AppListTile(
            title: Text(LocaleKeys.more_about_build.tr()),
            subtitle: Text(
              info.buildNumber,
              key: const ValueKey('about-build'),
            ),
          ),
        if (flavor != Flavor.prod)
          AppListTile(
            title: Text(LocaleKeys.more_about_flavor.tr()),
            subtitle: Text(flavor.name, key: const ValueKey('about-flavor')),
          ),
        AppListTile(
          key: const ValueKey('about-licenses'),
          leading: const Icon(Icons.description_outlined),
          title: Text(LocaleKeys.more_about_licenses.tr()),
          showChevron: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: info.name,
            applicationVersion: info.versionLabel,
          ),
        ),
        SizedBox(height: spacing.xl),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                key: const ValueKey('about-share'),
                label: LocaleKeys.more_about_share.tr(),
                icon: Icons.share_outlined,
                fullWidth: true,
                onPressed: () => _share(context, ref),
              ),
              SizedBox(height: spacing.md),
              AppButton(
                key: const ValueKey('about-rate'),
                label: LocaleKeys.more_about_rate.tr(),
                icon: Icons.star_outline,
                variant: AppButtonVariant.outlined,
                fullWidth: true,
                onPressed: () => _rate(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
