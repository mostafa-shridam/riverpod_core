import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/notification_providers.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router.dart';
import 'package:riverpod_core/core/router/routes.dart';

part 'notification_router_provider.g.dart';

/// The one [NotificationRouter]. Taps wait in its queue until the app router
/// is attached and the user is signed in; `routeForDeepLink` is the route map.
@Riverpod(keepAlive: true)
NotificationRouter notificationRouter(Ref ref) {
  final router = NotificationRouter(
    resolver: routeForDeepLink,
    openUrl: ref.watch(notificationUrlOpenerProvider),
    logger: () => ref.read(loggerProvider),
  );
  ref
    ..listen(
      sessionControllerProvider,
      (previous, next) =>
          router.setSessionReady(ready: next == SessionStatus.signedIn),
      fireImmediately: true,
    )
    ..onDispose(router.dispose);
  return router;
}
