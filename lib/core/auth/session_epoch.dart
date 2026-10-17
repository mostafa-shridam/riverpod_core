import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_epoch.g.dart';

/// Counts sign-outs. Logout bumps it; providers that hold user data watch it
/// (`ref.watch(sessionEpochProvider)`) and rebuild, so no user data survives
/// a sign-out. This is the session invalidation mechanism, chosen over a
/// root container reset because it needs no change to `ProviderScope`.
@Riverpod(keepAlive: true)
class SessionEpoch extends _$SessionEpoch {
  @override
  int build() => 0;

  void bump() => state++;
}
