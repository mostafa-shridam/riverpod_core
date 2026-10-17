import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';

part 'analytics_route_observer.g.dart';

/// Logs a screen view whenever a named page route becomes the top route.
/// Unnamed routes (dialogs, sheets) are ignored. Give it to the router's
/// `observers` list.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService Function() _analytics;
  String? _last;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(previousRoute);

  void _log(Route<dynamic>? route) {
    if (route is! PageRoute<dynamic>) return;
    final name = route.settings.name;
    if (name == null || name == _last) return;
    _last = name;
    _analytics().logScreenView(name).ignore();
  }
}

/// The screen-view observer. Add it to the GoRouter `observers`.
@Riverpod(keepAlive: true)
AnalyticsRouteObserver analyticsRouteObserver(Ref ref) =>
    AnalyticsRouteObserver(() => ref.read(analyticsServiceProvider));
