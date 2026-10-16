import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/auth/auth_endpoints.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/auth/session_epoch.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

import '../../helpers/helpers.dart';

const _tokens = AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
const _user = AuthUser(id: 'u1', email: 'ana@example.com', name: 'Ana');

/// Records calls, so logout's analytics steps can be asserted.
class _RecordingAnalytics implements AnalyticsService {
  final calls = <String>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {}

  @override
  Future<void> setUserId(String? userId) async =>
      calls.add('setUserId:$userId');

  @override
  Future<void> reset() async => calls.add('reset');
}

AppConfig _config() => const AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
);

class _Harness {
  _Harness({
    required this.container,
    required this.secure,
    required this.analytics,
    required this.adapter,
    required this.database,
  });

  final ProviderContainer container;
  final FakeSecureStorage secure;
  final _RecordingAnalytics analytics;
  final FakeHttpAdapter adapter;
  final AppDatabase database;

  SessionController get session =>
      container.read(sessionControllerProvider.notifier);
  SessionStatus get state => container.read(sessionControllerProvider);
  AuthUser? get user => container.read(sessionUserProvider);
}

Future<_Harness> _harness({Map<String, String> secure = const {}}) async {
  final prefs = await fakePrefsStorage({PrefKeys.themeMode: 'dark'});
  final database = AppDatabase.inMemory();
  final analytics = _RecordingAnalytics();
  final fakeSecure = FakeSecureStorage(secure);
  final adapter = FakeHttpAdapter();
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_config()),
      secureStorageProvider.overrideWithValue(fakeSecure),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      appDatabaseProvider.overrideWithValue(database),
      analyticsServiceProvider.overrideWithValue(analytics),
      httpClientAdapterProvider.overrideWithValue(adapter),
    ],
  );
  return _Harness(
    container: container,
    secure: fakeSecure,
    analytics: analytics,
    adapter: adapter,
    database: database,
  );
}

void main() {
  group('restore', () {
    test('no stored token means signed out', () async {
      final h = await _harness();
      addTearDown(h.database.close);

      await h.session.restore();

      expect(h.state, SessionStatus.signedOut);
      expect(h.user, isNull);
    });

    test('stored tokens restore the signed-in user', () async {
      final h = await _harness(
        secure: {
          SecureKeys.accessToken: 'access-1',
          SecureKeys.refreshToken: 'refresh-1',
          'auth.user': jsonEncode(_user.toJson()),
        },
      );
      addTearDown(h.database.close);

      await h.session.restore();

      expect(h.state, SessionStatus.signedIn);
      expect(h.user, _user);
    });

    test(
      'a corrupt stored user keeps the session but drops the user',
      () async {
        final h = await _harness(
          secure: {SecureKeys.accessToken: 'access-1', 'auth.user': 'not json'},
        );
        addTearDown(h.database.close);

        await h.session.restore();

        expect(h.state, SessionStatus.signedIn);
        expect(h.user, isNull);
      },
    );
  });

  group('signIn', () {
    test('stores tokens and user, then reports signed in', () async {
      final h = await _harness();
      addTearDown(h.database.close);

      await h.session.signIn(tokens: _tokens, user: _user);

      expect(h.state, SessionStatus.signedIn);
      expect(h.user, _user);
      expect(h.secure.values[SecureKeys.accessToken], 'access-1');
      expect(h.secure.values[SecureKeys.refreshToken], 'refresh-1');
      expect(h.secure.values['auth.user'], isNotNull);
    });
  });

  group('refreshAccessToken', () {
    test('renews the tokens through the refresh client', () async {
      final h = await _harness(secure: {SecureKeys.refreshToken: 'refresh-1'});
      addTearDown(h.database.close);
      h.adapter.enqueueJson(200, {
        'accessToken': 'access-2',
        'refreshToken': 'refresh-2',
      });

      final token = await h.session.refreshAccessToken();

      expect(token, 'access-2');
      expect(h.secure.values[SecureKeys.accessToken], 'access-2');
      expect(h.secure.values[SecureKeys.refreshToken], 'refresh-2');
      expect(h.adapter.requests.single.path, AuthEndpoints.refresh);
    });

    test('without a refresh token it fails as unauthorized', () async {
      final h = await _harness();
      addTearDown(h.database.close);

      await expectLater(
        h.session.refreshAccessToken(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('is the refresher the Dio client uses', () async {
      final h = await _harness();
      addTearDown(h.database.close);

      final refresher = h.container.read(accessTokenRefresherProvider);

      expect(refresher, same(h.session));
    });
  });

  group('session expiry', () {
    test('the expired signal signs the user out and wipes the user', () async {
      final h = await _harness(
        secure: {
          SecureKeys.accessToken: 'access-1',
          'auth.user': jsonEncode(_user.toJson()),
        },
      );
      addTearDown(h.database.close);
      await h.session.restore();
      final epochBefore = h.container.read(sessionEpochProvider);

      h.container.read(sessionEventsProvider).notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(h.state, SessionStatus.signedOut);
      expect(h.user, isNull);
      expect(h.secure.values.containsKey('auth.user'), isFalse);
      expect(h.container.read(sessionEpochProvider), epochBefore + 1);
    });
  });

  group('logout', () {
    Future<_Harness> signedIn() async {
      final h = await _harness();
      await h.session.signIn(tokens: _tokens, user: _user);
      await h.database.writeCache(
        key: 'user-1/orders',
        payload: '[]',
        savedAt: DateTime.utc(2026),
      );
      await h.container
          .read(prefsStorageProvider.future)
          .then((prefs) => prefs.setNotificationsEnabled(value: false));
      return h;
    }

    test('wipes secrets, cache and user settings and signs out', () async {
      final h = await signedIn();
      addTearDown(h.database.close);

      await h.session.logout();

      expect(h.state, SessionStatus.signedOut);
      expect(h.user, isNull);
      expect(h.secure.values, isEmpty);
      expect(await h.database.readCache('user-1/orders'), isNull);
      final prefs = await h.container.read(prefsStorageProvider.future);
      expect(prefs.notificationsEnabled, isTrue, reason: 'user setting reset');
      expect(prefs.themeMode, 'dark', reason: 'device setting kept');
    });

    test('clears analytics and bumps the session epoch', () async {
      final h = await signedIn();
      addTearDown(h.database.close);
      final epochBefore = h.container.read(sessionEpochProvider);

      await h.session.logout();

      expect(h.analytics.calls, ['setUserId:null', 'reset']);
      expect(h.container.read(sessionEpochProvider), epochBefore + 1);
    });

    test('calls the remote logout before the local wipe', () async {
      final h = await signedIn();
      addTearDown(h.database.close);
      var remoteSawTokens = false;

      await h.session.logout(
        remoteLogout: () async {
          remoteSawTokens = h.secure.values.containsKey(SecureKeys.accessToken);
        },
      );

      expect(remoteSawTokens, isTrue);
      expect(h.secure.values, isEmpty);
    });

    test('a failing remote logout does not block the local wipe', () async {
      final h = await signedIn();
      addTearDown(h.database.close);

      await h.session.logout(
        remoteLogout: () async {
          throw const NetworkException();
        },
      );

      expect(h.state, SessionStatus.signedOut);
      expect(h.secure.values, isEmpty);
    });
  });
}
