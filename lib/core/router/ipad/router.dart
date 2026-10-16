import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/router/app_routing_base.dart';

class IPadRouting extends AppRoutingBase {
  @override
  GoRouter getRoutes({List<NavigatorObserver>? observers}) {
    return GoRouter(
      //initialLocation: initialLocation,
      observers: observers,
      debugLogDiagnostics: true,
      initialLocation: '/',
      redirect: (context, state) {
        return null;
      },
      routes: [],
    );
  }
}
