import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/app/router/routes.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/features/showcase/presentation/pages/showcase_page.dart';

class HomePage extends ConsumerWidget {
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
              title: Text('showcase.entry'.tr()),
              subtitle: Text('showcase.entryHint'.tr()),
              showChevron: true,
              onTap: () => const ShowcaseRoute().push<void>(context),
            ),
        ],
      ),
    );
  }
}
