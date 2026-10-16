import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router_provider.dart';
import 'package:riverpod_core/core/router/app_error_page.dart';
import 'package:riverpod_core/core/router/guards/app_redirect.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';
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
    ..listen(onboardingSeenProvider, (previous, next) => refresh.value++)
    ..listen(startupReadyProvider, (previous, next) => refresh.value++);

  final router = GoRouter(
    initialLocation: SplashPage.routeName,
    refreshListenable: refresh,
    redirect: (context, state) => appRedirect(
      location: state.uri.path,
      session: ref.read(sessionControllerProvider),
      onboardingSeen: ref.read(onboardingSeenProvider),
      startupReady: ref.read(startupReadyProvider),
    ),
    errorBuilder: (context, state) => const AppErrorPage(),
    routes: $appRoutes,
  );

  // Notification taps (push and local) are resolved by NotificationRouter and
  // opened here; it queues them until the user is signed in.
  final notifications = ref.watch(notificationRouterProvider)
    ..attach((route) => router.go(route.location));
  ref.onDispose(() {
    notifications.detach();
    router.dispose();
  });
  return router;
}
