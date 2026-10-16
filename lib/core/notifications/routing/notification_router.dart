import 'dart:async';
import 'dart:collection';

import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';

/// Maps a `(type, id)` request to a typed route; null for an unknown type.
/// The app passes `routeForDeepLink`.
typedef DeepLinkResolver =
    GoRouteData? Function({required String type, required String id});

/// Opens an external web page.
typedef NotificationUrlOpener = Future<void> Function(Uri url);

/// Navigates to a resolved route (the app router's `go`).
typedef NotificationRouteOpener = void Function(GoRouteData route);

/// The single door from any notification tap to the app's navigation.
///
/// Push taps (background, cold start) and local taps (running, cold start)
/// all arrive in [handle]. A tap with `type` and `id` is resolved to a typed
/// route; otherwise a `url` is opened; anything else is ignored. A tap that
/// arrives before the app can navigate (no router attached yet, or the user
/// is not signed in) is queued and replayed in order when both are ready.
class NotificationRouter {
  NotificationRouter({
    required DeepLinkResolver resolver,
    required NotificationUrlOpener openUrl,
    required AppLogger Function() logger,
    this.maxQueued = 5,
  }) : _resolver = resolver,
       _openUrl = openUrl,
       _loggerOf = logger;

  final DeepLinkResolver _resolver;
  final NotificationUrlOpener _openUrl;
  // Lazy: the logger needs the app config, which taps must not wait for.
  final AppLogger Function() _loggerOf;
  AppLogger get _logger => _loggerOf();

  /// Longest queue kept; the oldest tap is dropped first.
  final int maxQueued;

  final Queue<NotificationTap> _queue = Queue<NotificationTap>();
  final StreamController<NotificationTap> _actions =
      StreamController<NotificationTap>.broadcast();

  NotificationRouteOpener? _opener;
  bool _sessionReady = false;

  /// Presses of action buttons (`actionId` set), for example the inline reply.
  /// They are not navigation and are never queued.
  Stream<NotificationTap> get actions => _actions.stream;

  /// Taps waiting for the router or the session.
  int get queuedCount => _queue.length;

  /// True when taps are handled immediately.
  bool get isReady => _sessionReady && _opener != null;

  /// Connects the app router. Replays queued taps when the session is ready.
  void attach(NotificationRouteOpener opener) {
    _opener = opener;
    _flush();
  }

  /// Disconnects the app router (it was disposed).
  void detach() => _opener = null;

  /// Tells whether the user can be taken to a screen (signed in).
  void setSessionReady({required bool ready}) {
    _sessionReady = ready;
    _flush();
  }

  /// Handles a tap now, or queues it until [isReady].
  void handle(NotificationTap tap) {
    if (tap.actionId != null) {
      if (!_actions.isClosed) _actions.add(tap);
      return;
    }
    if (tap.payload.isEmpty) {
      _logger.debug('Notification tap without a target ignored');
      return;
    }
    if (!isReady) {
      _queue.add(tap);
      while (_queue.length > maxQueued) {
        _queue.removeFirst();
      }
      return;
    }
    _dispatch(tap);
  }

  void _flush() {
    while (isReady && _queue.isNotEmpty) {
      _dispatch(_queue.removeFirst());
    }
  }

  void _dispatch(NotificationTap tap) {
    final payload = tap.payload;
    if (payload.hasRoute) {
      final route = _resolver(type: payload.type!, id: payload.id!);
      if (route != null) {
        _opener?.call(route);
        return;
      }
    }
    final url = _safeUrl(payload.url);
    if (url != null) {
      unawaited(_open(url));
      return;
    }
    _logger.debug('Notification tap ignored: unknown type "${payload.type}"');
  }

  Future<void> _open(Uri url) async {
    try {
      await _openUrl(url);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Could not open notification url',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Only web links: a payload must not be able to start other apps.
  static Uri? _safeUrl(String? raw) {
    if (raw == null) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return null;
    }
    return uri.host.isEmpty ? null : uri;
  }

  /// Closes the actions stream.
  Future<void> dispose() => _actions.close();
}
