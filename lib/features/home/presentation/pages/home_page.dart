import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

class HomePage extends ConsumerWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dev-only area: reference features are hidden in prod (D-028).
    final devArea = ref.watch(appConfigProvider).flavor != Flavor.prod;
    return Scaffold(
      key: const ValueKey('home-page'),
      appBar: AppBar(title: Text('app_nav.home'.tr())),
      body: devArea
          ? ListView(
              padding: EdgeInsets.all(context.tokens.spacing.lg),
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: AppListTile(
                    key: const ValueKey('home-videos-tile'),
                    leading: const Icon(Icons.video_library_outlined),
                    title: Text(LocaleKeys.videos_home_title.tr()),
                    subtitle: Text(LocaleKeys.videos_home_subtitle.tr()),
                    showChevron: true,
                    onTap: () => const VideosRoute().push<void>(context),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
