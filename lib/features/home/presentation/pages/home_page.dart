import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/showcase/presentation/pages/showcase_page.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

class HomePage extends ConsumerWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appConfigProvider.select((c) => c.flavor));
    // Dev-only area (D-028): the reference features exist outside prod only.
    final devArea = flavor != Flavor.prod;
    return Scaffold(
      key: const ValueKey('home-page'),
      appBar: AppBar(title: Text(LocaleKeys.app_nav_home.tr())),
      body: ListView(
        children: [
          if (ShowcasePage.isEnabled(flavor))
            AppListTile(
              key: const ValueKey('open-showcase'),
              leading: const Icon(Icons.widgets_outlined),
              title: Text(LocaleKeys.showcase_entry.tr()),
              subtitle: Text(LocaleKeys.showcase_entryHint.tr()),
              showChevron: true,
              onTap: () => const ShowcaseRoute().push<void>(context),
            ),
          if (devArea)
            AppListTile(
              key: const ValueKey('home-videos-tile'),
              leading: const Icon(Icons.video_library_outlined),
              title: Text(LocaleKeys.videos_home_title.tr()),
              subtitle: Text(LocaleKeys.videos_home_subtitle.tr()),
              showChevron: true,
              onTap: () => const VideosRoute().push<void>(context),
            ),
        ],
      ),
    );
  }
}
