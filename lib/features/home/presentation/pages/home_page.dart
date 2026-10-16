import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/config/app_config.dart';
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
    return Scaffold(
      key: const ValueKey('home-page'),
      appBar: AppBar(title: Text('app_nav.home'.tr())),
      body: ListView(
        children: [
          // Developer entry point: the gallery exists only outside prod.
          if (ShowcasePage.isEnabled(flavor))
            AppListTile(
              key: const ValueKey('open-showcase'),
              leading: const Icon(Icons.widgets_outlined),
              title: Text(LocaleKeys.showcase_entry.tr()),
              subtitle: Text(LocaleKeys.showcase_entryHint.tr()),
              showChevron: true,
              onTap: () => const ShowcaseRoute().push<void>(context),
            ),
        ],
      ),
    );
  }
}
