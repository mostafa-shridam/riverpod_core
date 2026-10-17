import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';

part 'token_refresher.g.dart';

/// Renews the access token and stores the new one. The auth feature provides the real
/// implementation (it owns the refresh endpoint); the network layer only calls
/// it. Throws when the session cannot be renewed.
abstract interface class AccessTokenRefresher {
  Future<String> refreshAccessToken();
}

/// Lets one refresh run at a time. Callers that arrive while it runs share
/// its result, so N concurrent 401s cause one refresh.
class SingleFlightRefresher implements AccessTokenRefresher {
  SingleFlightRefresher(this._inner);

  final AccessTokenRefresher _inner;
  Future<String>? _inFlight;

  @override
  Future<String> refreshAccessToken() {
    final running = _inFlight;
    if (running != null) return running;
    final refresh = _inner.refreshAccessToken().whenComplete(
      () => _inFlight = null,
    );
    _inFlight = refresh;
    return refresh;
  }
}

/// Fallback refresher: every attempt fails, so an expired session is reported
/// as expired instead of retried forever. Not bound by default any more.
class UnconfiguredRefresher implements AccessTokenRefresher {
  const UnconfiguredRefresher();

  @override
  Future<String> refreshAccessToken() async {
    throw const UnauthorizedException(
      message: 'Token refresh is not configured',
    );
  }
}

/// The refresher bound by the app. [dioProvider] wraps it in a
/// [SingleFlightRefresher]. The session controller renews the tokens.
@Riverpod(keepAlive: true)
AccessTokenRefresher accessTokenRefresher(Ref ref) {
  return ref.watch(sessionControllerProvider.notifier);
}
