import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/local_services/local_storage.dart';
import 'package:riverpod_core/core/notifications/local_notifications_service.dart';
import 'package:riverpod_core/core/router/index.dart';
import 'package:riverpod_core/core/services/helper.dart';
import 'package:riverpod_core/core/services/life_cycle_manager.dart';
import 'package:riverpod_core/core/services/scroll_behavior.dart';
import 'package:riverpod_core/core/themes/style.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';

Future<void> firstInit() async {
  try {
    await LocalStorage.instance.init();
  } catch (e) {
    log('Error when init LocalStorage: $e');
  }

  try {
    await LocalNotificationsService.instance.init();
  } catch (e) {
    log('Error when init LocalNotificationsService: $e');
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await firstInit();
      runApp(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: supportedLocales,
            path: translationsPath,
            fallbackLocale: Locale(getLanguageCodeHelper()),
            startLocale: Locale(getLanguageCodeHelper()),
            assetLoader: const CodegenLoader(),
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stackTrace) {
      log('Error: $error');
      log('Stack trace: $stackTrace');
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
          scaffoldMessengerKey: scaffoldMessengerKey,
          scrollBehavior: CustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          routerConfig: Routes.instance.getRoutes(),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return ResponsiveScaledBox(
              width: ResponsiveValue<double?>(
                context,
                conditionalValues: [
                  if (kIsWeb)
                    Condition.equals(
                      name: DESKTOP,
                      value: mediaQueryData.size.width,
                    ),
                  const Condition.equals(name: MOBILE, value: 450),
                  const Condition.between(start: 601, end: 800, value: 800),
                  Condition.between(
                    start: 801,
                    end: 1200,
                    value: mediaQueryData.size.width,
                  ),
                  Condition.largerThan(
                    name: TABLET,
                    value: mediaQueryData.size.width,
                  ),
                ],
              ).value,
              child: MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: const TextScaler.linear(1),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
