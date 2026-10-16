import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/app/router/app_error_page.dart';
import 'package:riverpod_core/app/router/guards/app_redirect.dart';
import 'package:riverpod_core/app/router/routes.dart';
import 'package:riverpod_core/app/startup/splash_page.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/helper/deep_link_helper.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'app_router.g.dart';

/// Whether onboarding was seen. Null while the settings are still loading.
@Riverpod(keepAlive: true)
bool? onboardingSeen(Ref ref) {
  return ref.watch(prefsStorageProvider).value?.onboardingSeen;
}

/// The one router of the app (D-016). Redirects are [appRedirect]; the router
/// re-runs them whenever session or onboarding state changes.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(sessionControllerProvider, (previous, next) => refresh.value++)
    ..listen(onboardingSeenProvider, (previous, next) => refresh.value++);

  final router = GoRouter(
    initialLocation: SplashPage.routeName,
    refreshListenable: refresh,
    redirect: (context, state) => appRedirect(
      location: state.uri.path,
      session: ref.read(sessionControllerProvider),
      onboardingSeen: ref.read(onboardingSeenProvider),
    ),
    errorBuilder: (context, state) => const AppErrorPage(),
    routes: $appRoutes,
  );

  // Notification taps arrive as events; they open the matching typed route.
  final links = DeepLinkHelper.instance.events.listen((event) {
    final route = routeForDeepLink(type: event.type, id: event.id);
    if (route != null) router.go(route.location);
  });
  ref.onDispose(() {
    links.cancel();
    router.dispose();
  });
  return router;
}
