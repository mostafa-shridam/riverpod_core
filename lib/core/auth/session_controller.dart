import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/network/session_events.dart';

part 'session_controller.g.dart';

/// Whether the user is signed in, as far as the app knows yet.
enum SessionStatus { unknown, signedOut, signedIn }

/// Single owner of the session state that routing guards read.
///
/// STUB (C-11): C-17 replaces the sign-in flow and the startup restore. It
/// already consumes [SessionEvents.expired]: an expired session signs out.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  SessionStatus build() {
    final subscription = ref
        .read(sessionEventsProvider)
        .expired
        .listen((_) => state = SessionStatus.signedOut);
    ref.onDispose(subscription.cancel);
    return SessionStatus.unknown;
  }

  /// Startup restore. Stub: with no stored session yet, the user is signed out.
  void restore() {
    if (state == SessionStatus.unknown) state = SessionStatus.signedOut;
  }

  void signIn() {
    state = SessionStatus.signedIn;
    ref.read(sessionEventsProvider).markSignedIn();
  }

  void signOut() => state = SessionStatus.signedOut;
}
