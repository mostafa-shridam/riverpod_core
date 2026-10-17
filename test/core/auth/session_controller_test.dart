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
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
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
    required this.cache,
  });

  final ProviderContainer container;
  final FakeSecureStorage secure;
  final _RecordingAnalytics analytics;
  final FakeHttpAdapter adapter;
  final CacheStore cache;

  SessionController get session =>
      container.read(sessionControllerProvider.notifier);
  SessionStatus get state => container.read(sessionControllerProvider);
  AuthUser? get user => container.read(sessionUserProvider);
}

Future<_Harness> _harness({
  Map<String, String> secure = const {},
  Future<void> Function()? notificationLogout,
}) async {
  final storage = await openTestStorage();
  await storage.settings.putAll({PrefKeys.themeMode: 'dark'});
  final prefs = PrefsStorage(storage.settings);
  final cache = CacheStore(storage.cache);
  final analytics = _RecordingAnalytics();
  final fakeSecure = FakeSecureStorage(secure);
  final adapter = FakeHttpAdapter();
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_config()),
      secureStorageProvider.overrideWithValue(fakeSecure),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      cacheStoreProvider.overrideWithValue(cache),
      analyticsServiceProvider.overrideWithValue(analytics),
      httpClientAdapterProvider.overrideWithValue(adapter),
      // Real notification plugins are never touched in these tests.
      notificationLogoutProvider.overrideWith(
        (ref) => notificationLogout ?? () async {},
      ),
    ],
  );
  return _Harness(
    container: container,
    secure: fakeSecure,
    analytics: analytics,
    adapter: adapter,
    cache: cache,
  );
}

void main() {
  group('restore', () {
    test('no stored token means signed out', () async {
      final h = await _harness();

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

        await h.session.restore();

        expect(h.state, SessionStatus.signedIn);
        expect(h.user, isNull);
      },
    );
  });

  group('signIn', () {
    test('stores tokens and user, then reports signed in', () async {
      final h = await _harness();

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

      await expectLater(
        h.session.refreshAccessToken(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('is the refresher the Dio client uses', () async {
      final h = await _harness();

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
    Future<_Harness> signedIn({
      Future<void> Function()? notificationLogout,
    }) async {
      final h = await _harness(notificationLogout: notificationLogout);
      await h.session.signIn(tokens: _tokens, user: _user);
      await h.cache.write(
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

      await h.session.logout();

      expect(h.state, SessionStatus.signedOut);
      expect(h.user, isNull);
      expect(h.secure.values, isEmpty);
      expect(h.cache.read('user-1/orders'), isNull);
      final prefs = await h.container.read(prefsStorageProvider.future);
      expect(prefs.notificationsEnabled, isTrue, reason: 'user setting reset');
      expect(prefs.themeMode, 'dark', reason: 'device setting kept');
    });

    test('clears analytics and bumps the session epoch', () async {
      final h = await signedIn();
      final epochBefore = h.container.read(sessionEpochProvider);

      await h.session.logout();

      expect(h.analytics.calls, ['setUserId:null', 'reset']);
      expect(h.container.read(sessionEpochProvider), epochBefore + 1);
    });

    test('calls the remote logout before the local wipe', () async {
      final h = await signedIn();
      var remoteSawTokens = false;

      await h.session.logout(
        remoteLogout: () async {
          remoteSawTokens = h.secure.values.containsKey(SecureKeys.accessToken);
        },
      );

      expect(remoteSawTokens, isTrue);
      expect(h.secure.values, isEmpty);
    });

    test(
      'the notification hook runs before the remote logout and the wipe',
      () async {
        final events = <String>[];
        late final _Harness h;
        h = await signedIn(
          notificationLogout: () async {
            events.add(
              'notifications, token kept: '
              '${h.secure.values.containsKey(SecureKeys.accessToken)}',
            );
          },
        );

        await h.session.logout(
          remoteLogout: () async {
            events.add(
              'remote, token kept: '
              '${h.secure.values.containsKey(SecureKeys.accessToken)}',
            );
          },
        );

        expect(events, [
          'notifications, token kept: true',
          'remote, token kept: true',
        ]);
        expect(h.secure.values, isEmpty);
      },
    );

    test('a failing notification hook does not block logout', () async {
      final h = await signedIn(
        notificationLogout: () async {
          throw const NetworkException();
        },
      );

      await h.session.logout();

      expect(h.state, SessionStatus.signedOut);
      expect(h.secure.values, isEmpty);
    });

    test('a failing remote logout does not block the local wipe', () async {
      final h = await signedIn();

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
