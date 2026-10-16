import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/router/app_shell.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/items/presentation/pages/item_detail_page.dart';
import 'package:riverpod_core/features/more/presentation/pages/more_page.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:riverpod_core/features/videos/presentation/pages/video_detail_page.dart';
import 'package:riverpod_core/features/videos/presentation/pages/videos_page.dart';

part 'routes.g.dart';

@TypedGoRoute<SplashRoute>(path: SplashPage.routeName)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<OnboardingRoute>(path: OnboardingPage.routeName)
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingPage();
}

@TypedGoRoute<LoginRoute>(path: LoginPage.routeName)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: HomePage.routeName)],
    ),
    TypedStatefulShellBranch<MoreBranch>(
      routes: [TypedGoRoute<MoreRoute>(path: MorePage.routeName)],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShell(navigationShell: navigationShell);
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class MoreBranch extends StatefulShellBranchData {
  const MoreBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class MoreRoute extends GoRouteData with $MoreRoute {
  const MoreRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MorePage();
}

@TypedGoRoute<ItemDetailRoute>(path: '${ItemDetailPage.routeName}/:id')
class ItemDetailRoute extends GoRouteData with $ItemDetailRoute {
  const ItemDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ItemDetailPage(id: id);
}

/// Maps a deep-link or notification request to a typed route. Null when the
/// type is unknown, so the request is ignored instead of guessed.
GoRouteData? routeForDeepLink({required String type, required String id}) {
  return switch (type) {
    'myEvents' => ItemDetailRoute(id: id),
    _ => null,
  };
}

/// Dev and staging only (D-028): in a prod build these routes redirect home,
/// so a deep link cannot reach the reference feature. The entry points are
/// hidden by the same flavor check (home tile, `videosSimulationEnabled`).
String? _devOnlyRedirect(BuildContext context) {
  final flavor = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(appConfigProvider).flavor;
  return flavor == Flavor.prod ? HomePage.routeName : null;
}

@TypedGoRoute<VideosRoute>(path: VideosPage.routeName)
class VideosRoute extends GoRouteData with $VideosRoute {
  const VideosRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      _devOnlyRedirect(context);

  @override
  Widget build(BuildContext context, GoRouterState state) => const VideosPage();
}

@TypedGoRoute<VideoDetailRoute>(path: VideoDetailPage.routeName)
class VideoDetailRoute extends GoRouteData with $VideoDetailRoute {
  const VideoDetailRoute({required this.id, this.url});

  final String id;

  /// A pasted link to play; only used with `id == customVideoId`.
  final String? url;

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      _devOnlyRedirect(context);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VideoDetailPage(id: id, customUrl: url);
}
