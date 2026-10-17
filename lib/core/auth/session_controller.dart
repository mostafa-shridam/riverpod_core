import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/auth/auth_endpoints.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/auth/session_epoch.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/clear_user_data.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

part 'session_controller.g.dart';

/// Whether the user is signed in, as far as the app knows yet.
enum SessionStatus { unknown, signedOut, signedIn }

/// Secure-storage key of the signed-in user's JSON.
const _userKey = 'auth.user';

/// The signed-in user, or null. Kept apart from [SessionStatus] so guards
/// only watch the status.
@Riverpod(keepAlive: true)
class SessionUser extends _$SessionUser {
  @override
  AuthUser? build() => null;

  void update(AuthUser? user) => state = user;
}

/// Single owner of the session. Guards read the [SessionStatus]. The
/// controller is also the app's [AccessTokenRefresher], so the Dio refresh
/// works through it.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController
    implements AccessTokenRefresher {
  @override
  SessionStatus build() {
    final subscription = ref
        .read(sessionEventsProvider)
        .expired
        .listen((_) => _endLocally());
    ref.onDispose(subscription.cancel);
    return SessionStatus.unknown;
  }

  SecureStorage get _secure => ref.read(secureStorageProvider);

  /// Startup: signed in when tokens are stored, signed out otherwise. A stored
  /// access token that has expired is renewed on the first 401.
  Future<void> restore() async {
    if (state != SessionStatus.unknown) return;
    final token = await _secure.readAccessToken();
    if (state != SessionStatus.unknown) return;
    if (token == null || token.isEmpty) {
      state = SessionStatus.signedOut;
      return;
    }
    ref
        .read(sessionUserProvider.notifier)
        .update(_decodeUser(await _secure.read(_userKey)));
    state = SessionStatus.signedIn;
  }

  /// Stores the tokens and the user, then marks the session as signed in.
  Future<void> signIn({
    required AuthTokens tokens,
    required AuthUser user,
  }) async {
    await _storeTokens(tokens);
    await _secure.write(_userKey, jsonEncode(user.toJson()));
    ref.read(sessionEventsProvider).markSignedIn();
    ref.read(sessionUserProvider.notifier).update(user);
    state = SessionStatus.signedIn;
  }

  /// Renews the access token with the stored refresh token. Called by the Dio
  /// refresh interceptor (single-flight).
  @override
  Future<String> refreshAccessToken() async {
    final refresh = await _secure.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw const UnauthorizedException(message: 'No refresh token stored');
    }
    final response = await ref
        .read(refreshDioProvider)
        .post<Map<String, dynamic>>(
          AuthEndpoints.refresh,
          data: {'refreshToken': refresh},
        );
    final tokens = AuthTokens.fromJson(response.data ?? const {});
    await _storeTokens(tokens);
    return tokens.accessToken;
  }

  /// Signs out everywhere on this device. The ONE logout path:
  /// 1. notifications unregister this device (`notificationLogoutProvider`),
  ///    best effort; it needs the session, so it runs before the wipe;
  /// 2. remote logout, best effort: a failure is logged and never blocks;
  /// 3. local wipe: secrets, cache and user-scoped settings (`clearUserData`);
  /// 4. analytics forgets the user;
  /// 5. [SessionEpoch] bumps, so user-scoped providers rebuild;
  /// 6. the session becomes signed out, and the router goes to login.
  Future<void> logout({Future<void> Function()? remoteLogout}) async {
    await _bestEffort(
      () => ref.read(notificationLogoutProvider)(),
      'Notification logout failed; clearing locally',
    );
    if (remoteLogout != null) {
      await _bestEffort(remoteLogout, 'Remote logout failed; clearing locally');
    }
    await clearUserData(
      secure: _secure,
      prefs: await ref.read(prefsStorageProvider.future),
      cache: ref.read(cacheStoreProvider),
    );
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.setUserId(null);
    await analytics.reset();
    ref.read(sessionEpochProvider.notifier).bump();
    ref.read(sessionUserProvider.notifier).update(null);
    state = SessionStatus.signedOut;
  }

  /// Runs one logout step. A failure is logged and never stops the wipe.
  Future<void> _bestEffort(
    Future<void> Function() step,
    String failureMessage,
  ) async {
    try {
      await step();
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .warning(failureMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Local sign-out without a remote call.
  Future<void> signOut() => logout();

  /// Expiry: the refresh failed. The tokens are already gone (the interceptor
  /// deletes them), so only the user and local state go.
  Future<void> _endLocally() async {
    await _secure.delete(_userKey);
    ref.read(sessionEpochProvider.notifier).bump();
    ref.read(sessionUserProvider.notifier).update(null);
    state = SessionStatus.signedOut;
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    await _secure.write(SecureKeys.accessToken, tokens.accessToken);
    await _secure.write(SecureKeys.refreshToken, tokens.refreshToken);
  }

  /// A corrupt stored user is treated as no user: the tokens still say signed
  /// in, and the user is shown again after the next sign-in.
  AuthUser? _decodeUser(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
