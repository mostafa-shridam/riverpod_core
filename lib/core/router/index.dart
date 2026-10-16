import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:riverpod_core/core/router/ipad/router.dart';
import 'package:riverpod_core/core/router/mobile/router.dart';
import 'package:riverpod_core/core/router/web/router.dart';

class Routes {
  Routes._internal();
  static final Routes _singleton = Routes._internal();
  static Routes get instance => _singleton;

  GoRouter? _router;

  // ده اللي هتستخدمه في handleMyEventRouteById
  GoRouter get router {
    // لو الـ router لسه متبناش، ابنيه
    _router ??= getRoutes();
    return _router!;
  }

  GoRouter getRoutes({
    List<NavigatorObserver>? observers,
    bool isMobile = true,
  }) {
    // أهم سطر: لو فيه router قديم شغال، رجعه هو هو
    if (_router != null) return _router!;

    final routing = kIsWeb
        ? WebRouting()
        : isMobile
        ? MobileRouting.instance
        : IPadRouting();

    _router = routing.getRoutes(observers: observers);
    return _router!;
  }
}
