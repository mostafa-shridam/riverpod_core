import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:riverpod_core/core/router/app_routing_base.dart';

class MobileRouting extends AppRoutingBase {
  // 1. Singleton Setup
  static final MobileRouting _singleton = MobileRouting._internal();
  MobileRouting._internal() {
    _router = _buildRouter();
  }
  static MobileRouting get instance => _singleton;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter _router;

  GoRouter get router => _router;

  @override
  GoRouter getRoutes({List<NavigatorObserver>? observers}) {
    return _router;
  }

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/',

      errorBuilder: (context, state) => const Scaffold(),
      redirect: (context, state) {
        // final isOnSplash = state.matchedLocation == SplashPage.routeName;

        // if (AppInit.splashVisited == false && !isOnSplash) {
        //   return SplashPage.routeName;
        // }
        // // if (state.uri.toString().contains('dlink') == true) {
        // //   return MainPage.routeName;
        // // }
        return null;
      },
      routes: [],
    );
  }
}
