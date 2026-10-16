import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/router/app_routing_base.dart';

class WebRouting extends AppRoutingBase {
  @override
  GoRouter getRoutes({List<NavigatorObserver>? observers}) {
    return GoRouter(
      observers: observers,
      debugLogDiagnostics: true,
      initialLocation: '/',
      routes: [],
    );
  }
}
