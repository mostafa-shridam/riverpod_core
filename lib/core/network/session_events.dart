import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_events.g.dart';

/// Signals that the session can no longer be renewed. The auth feature (C-17)
/// listens and sends the user to sign-in; C-07 only raises the signal.
class SessionEvents {
  final _expired = StreamController<void>.broadcast();
  bool _isExpired = false;

  /// One event per expiry: repeated failures of one lost session emit once.
  Stream<void> get expired => _expired.stream;

  void notifyExpired() {
    if (_isExpired) return;
    _isExpired = true;
    if (!_expired.isClosed) _expired.add(null);
  }

  /// Call after a successful sign-in so the next expiry is reported again.
  void markSignedIn() => _isExpired = false;

  Future<void> dispose() => _expired.close();
}

/// Session expiry signal for the whole app.
@Riverpod(keepAlive: true)
SessionEvents sessionEvents(Ref ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
}
