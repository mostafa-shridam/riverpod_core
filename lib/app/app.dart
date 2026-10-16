import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:riverpod_core/core/design_system/responsive/text_scale.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_messenger.dart';
import 'package:riverpod_core/core/router/index.dart';
import 'package:riverpod_core/core/services/life_cycle_manager.dart';
import 'package:riverpod_core/core/services/scroll_behavior.dart';

/// Root widget: theme, locale, text scale clamp and the router.
///
/// TODO(C-11): replace the legacy `Routes.instance` router with
/// `appRouterProvider`.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBreakpoints(
      breakpoints: [
        const Breakpoint(start: 0, end: 600, name: MOBILE),
        const Breakpoint(start: 601, end: 1200, name: TABLET),
        const Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
      ],
      child: LifeCycleManager(
        child: MaterialApp.router(
          scaffoldMessengerKey: ref.watch(appMessengerProvider).key,
          scrollBehavior: CustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          routerConfig: Routes.instance.getRoutes(),
          builder: (context, child) {
            // Keep the user's text scale (clamped), never a fixed one.
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: clampTextScale(mediaQueryData.textScaler),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
