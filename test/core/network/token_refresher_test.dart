import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';

class _ScriptedRefresher implements AccessTokenRefresher {
  _ScriptedRefresher(this._gate);

  final Completer<void> _gate;
  int calls = 0;

  @override
  Future<String> refreshAccessToken() async {
    calls++;
    await _gate.future;
    return 'token-$calls';
  }
}

void main() {
  group('SingleFlightRefresher', () {
    test('concurrent callers share one inner refresh', () async {
      final gate = Completer<void>();
      final inner = _ScriptedRefresher(gate);
      final refresher = SingleFlightRefresher(inner);

      final futures = [
        for (var i = 0; i < 4; i++) refresher.refreshAccessToken(),
      ];
      gate.complete();
      final results = await Future.wait(futures);

      expect(inner.calls, 1);
      expect(results, everyElement('token-1'));
    });

    test('a later call after completion refreshes again', () async {
      final open = Completer<void>()..complete();
      final inner = _ScriptedRefresher(open);
      final refresher = SingleFlightRefresher(inner);

      await refresher.refreshAccessToken();
      final second = await refresher.refreshAccessToken();

      expect(inner.calls, 2);
      expect(second, 'token-2');
    });

    test('a failed refresh is shared by all waiters, then cleared', () async {
      final gate = Completer<void>();
      final refresher = SingleFlightRefresher(_FailingRefresher(gate));

      final futures = [
        for (var i = 0; i < 3; i++) refresher.refreshAccessToken(),
      ];
      gate.complete();
      for (final future in futures) {
        await expectLater(future, throwsA(isA<UnauthorizedException>()));
      }

      // The failure does not stick: the next call runs a new refresh.
      await expectLater(
        refresher.refreshAccessToken(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('UnconfiguredRefresher', () {
    test('always fails so an expired session is reported', () async {
      await expectLater(
        const UnconfiguredRefresher().refreshAccessToken(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('SessionEvents', () {
    test('emits once per expiry, not once per failed request', () async {
      final events = SessionEvents();
      addTearDown(events.dispose);
      final emitted = <void>[];
      final sub = events.expired.listen(emitted.add);
      addTearDown(sub.cancel);

      events.notifyExpired();
      events.notifyExpired();
      events.notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, hasLength(1));
    });

    test('markSignedIn re-arms the signal', () async {
      final events = SessionEvents();
      addTearDown(events.dispose);
      final emitted = <void>[];
      final sub = events.expired.listen(emitted.add);
      addTearDown(sub.cancel);

      events.notifyExpired();
      events.markSignedIn();
      events.notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, hasLength(2));
    });
  });
}

class _FailingRefresher implements AccessTokenRefresher {
  _FailingRefresher(this._gate);

  final Completer<void> _gate;

  @override
  Future<String> refreshAccessToken() async {
    await _gate.future;
    throw const UnauthorizedException(message: 'rejected');
  }
}
