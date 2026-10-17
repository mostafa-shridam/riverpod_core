import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/app/scroll_behavior.dart';
import 'package:riverpod_core/core/design_system/responsive/text_scale.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_messenger.dart';
import 'package:riverpod_core/core/notifications/notification_label_sync.dart';
import 'package:riverpod_core/core/router/app_router.dart';
import 'package:riverpod_core/core/security/app_lock_overlay.dart';

/// Root widget: messenger, locale (easy_localization), theme, router, and the
/// clamped text scale. Breakpoints come from `design_system/responsive`.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      scaffoldMessengerKey: ref.watch(appMessengerProvider).key,
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: clampTextScale(mediaQuery.textScaler),
          ),
          child: NotificationLabelSync(child: AppLockOverlay(child: child!)),
        );
      },
    );
  }
}
