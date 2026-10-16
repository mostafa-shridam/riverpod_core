import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/device/device_info_provider.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/notification_providers.dart';
import 'package:riverpod_core/core/notifications/notification_service.dart';
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';
import 'package:riverpod_core/core/notifications/registration/noop_push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router_provider.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings_controller.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

import '../../helpers/fake_notification_backends.dart';
import '../../helpers/helpers.dart';

/// A container wired with fakes for every notification backend.
class _Harness {
  _Harness._(this.prefs) {
    container = createContainer(
      overrides: [
        prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
        secureStorageProvider.overrideWithValue(FakeSecureStorage()),
        appDatabaseProvider.overrideWithValue(AppDatabase.inMemory()),
        analyticsServiceProvider.overrideWithValue(
          const NoopAnalyticsService(),
        ),
        loggerProvider.overrideWithValue(recordingLogger(logs)),
        localNotificationBackendProvider.overrideWithValue(local),
        pushBackendProvider.overrideWithValue(push),
        notificationPermissionBackendProvider.overrideWithValue(permission),
        timezoneBackendProvider.overrideWithValue(FakeTimezoneBackend()),
        pushTokenRegistrarProvider.overrideWithValue(registrar),
        deviceInfoSourceProvider.overrideWithValue(FakeDeviceInfoSource()),
        notificationLabelResolverProvider.overrideWithValue((key) => key),
        notificationUrlOpenerProvider.overrideWithValue(
          (url) async => urls.add(url),
        ),
      ],
    );
  }

  static Future<_Harness> create([
    Map<String, Object> initialPrefs = const {},
  ]) async => _Harness._(await fakePrefsStorage(initialPrefs));

  final PrefsStorage prefs;
  late final ProviderContainer container;
  final local = FakeLocalNotificationBackend();
  final push = FakePushBackend();
  final permission = FakeNotificationPermissionBackend();
  final registrar = FakePushTokenRegistrar();
  final logs = <String>[];
  final urls = <Uri>[];
  final opened = <GoRouteData>[];

  NotificationService get service =>
      container.read(notificationServiceProvider);

  SessionController get session =>
      container.read(sessionControllerProvider.notifier);

  Future<void> settle() => pumpEventQueue();

  /// Signs in with fixture credentials; the notification hooks react to it.
  Future<void> signIn() => session.signIn(tokens: _tokens, user: _user);
}

const _tokens = AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
const _user = AuthUser(id: '1', email: 'ana@example.com', name: 'Ana');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initialize', () {
    test(
      'sets up local and push, creates channels, reports availability',
      () async {
        final h = await _Harness.create();

        await h.service.initialize();

        expect(h.local.timezoneName, 'Africa/Cairo');
        expect(h.local.createChannelsCalls, greaterThan(0));
        expect(h.local.channels, hasLength(4));
        expect(h.push.initializeCalls, 1);
        expect(h.container.read(pushAvailableProvider), isTrue);
      },
    );

    test('is idempotent', () async {
      final h = await _Harness.create();

      await h.service.initialize();
      await h.service.initialize();

      expect(h.push.initializeCalls, 1);
    });

    test('Firebase unavailable: push off, local keeps working', () async {
      final h = await _Harness.create();
      h.push.available = false;

      await h.service.initialize();

      expect(h.container.read(pushAvailableProvider), isFalse);
      expect(h.service.pushAvailable, isFalse);
      expect(h.logs.where((l) => l.contains('Push is disabled')), hasLength(1));
      expect(await h.service.local.show(title: 'T', body: 'B'), isNotNull);
      expect(h.local.shown, hasLength(1));
    });

    test('a push backend that throws does not break startup', () async {
      final h = await _Harness.create();
      h.push.failInitialize = true;

      await h.service.initialize();

      expect(h.container.read(pushAvailableProvider), isFalse);
      expect(h.logs.any((l) => l.contains('Push failed to start')), isTrue);
      expect(await h.service.local.show(title: 'T', body: 'B'), isNotNull);
    });

    test('a local backend that throws does not stop push', () async {
      final h = await _Harness.create();
      h.local.failInitialize = true;

      await h.service.initialize();

      expect(
        h.logs.any((l) => l.contains('Local notifications failed')),
        isTrue,
      );
      expect(h.container.read(pushAvailableProvider), isTrue);
    });

    test(
      'a tap that launched the app is routed once the user is signed in',
      () async {
        final h = await _Harness.create();
        h.local.launch = const NotificationTap(
          payload: NotificationPayload(type: 'myEvents', id: '8'),
          source: NotificationTapSource.localLaunch,
        );
        h.container.read(notificationRouterProvider).attach(h.opened.add);

        await h.service.initialize();
        expect(h.opened, isEmpty, reason: 'not signed in yet');

        await h.signIn();
        await h.settle();

        expect((h.opened.single as ItemDetailRoute).id, '8');
      },
    );

    test('the default registrar does nothing', () async {
      final container = createContainer();

      expect(
        container.read(pushTokenRegistrarProvider),
        isA<NoopPushTokenRegistrar>(),
      );
    });
  });

  group('session', () {
    test('sign-in registers the token', () async {
      final h = await _Harness.create();
      await h.service.initialize();

      await h.signIn();
      await h.settle();

      expect(h.registrar.registrations.single.token, 'token-1');
      expect(h.registrar.registrations.single.device.platform, 'android');
    });

    test('a token refresh after sign-in is registered', () async {
      final h = await _Harness.create();
      await h.service.initialize();
      await h.signIn();
      await h.settle();

      h.push.currentToken = 'token-2';
      h.push.refreshes.add('token-2');
      await h.settle();

      expect(h.registrar.registrations.map((r) => r.token), [
        'token-1',
        'token-2',
      ]);
    });

    test(
      'the logout hook unregisters, deletes the token, cancels scheduled',
      () async {
        final h = await _Harness.create();
        await h.service.initialize();
        await h.signIn();
        await h.settle();

        await h.container.read(notificationLogoutProvider)();

        expect(h.registrar.unregistered, ['token-1']);
        expect(h.push.deleteTokenCalls, 1);
        expect(h.local.cancelAllCalls, 1);
        expect(h.local.badges, [0]);
      },
    );

    test('an unannounced sign-out still cleans up', () async {
      final h = await _Harness.create();
      await h.service.initialize();
      await h.signIn();
      await h.settle();

      await h.session.signOut();
      await h.settle();

      expect(h.registrar.unregistered, ['token-1']);
      expect(h.push.deleteTokenCalls, 1);
    });

    test('without push, sign-in and logout do nothing remote', () async {
      final h = await _Harness.create();
      h.push.available = false;
      await h.service.initialize();

      await h.signIn();
      await h.settle();
      await h.service.onLogout();

      expect(h.registrar.registrations, isEmpty);
      expect(h.push.deleteTokenCalls, 0);
      expect(h.local.cancelAllCalls, 1);
    });
  });

  group('settings', () {
    test(
      'turning notifications off persists, cancels and unregisters',
      () async {
        final h = await _Harness.create();
        await h.service.initialize();
        await h.signIn();
        await h.settle();

        expect(await h.service.setEnabled(enabled: false), isTrue);

        expect(h.prefs.notificationsEnabled, isFalse);
        expect(h.local.cancelAllCalls, 1);
        expect(h.registrar.unregistered, ['token-1']);
        expect(h.push.presentation.last, isFalse);
        expect(await h.service.local.show(title: 'T', body: 'B'), isNull);
      },
    );

    test('turning them on again registers the token again', () async {
      final h = await _Harness.create();
      await h.service.initialize();
      await h.signIn();
      await h.settle();
      await h.service.setEnabled(enabled: false);

      await h.service.setEnabled(enabled: true);

      expect(h.prefs.notificationsEnabled, isTrue);
      expect(h.registrar.registrations, hasLength(2));
      expect(h.push.presentation.last, isTrue);
    });

    test(
      'a saved master-off flag keeps the token unregistered at sign-in',
      () async {
        final h = await _Harness.create({PrefKeys.notificationsEnabled: false});
        await h.service.initialize();

        await h.signIn();
        await h.settle();

        expect(h.registrar.registrations, isEmpty);
      },
    );

    test('a channel switch persists and silences that channel', () async {
      final h = await _Harness.create();
      await h.service.initialize();

      await h.service.setChannelEnabled('general', enabled: false);

      expect(h.prefs.getStringList(notificationDisabledChannelsKey), [
        'general',
      ]);
      expect(await h.service.local.show(title: 'T', body: 'B'), isNull);
      expect(
        await h.service.local.show(
          title: 'T',
          body: 'B',
          channelId: 'high_priority',
        ),
        isNotNull,
      );
    });

    test('channel labels can be refreshed', () async {
      final h = await _Harness.create();
      await h.service.initialize();
      final before = h.local.createChannelsCalls;

      await h.service.syncChannelLabels();

      expect(h.local.createChannelsCalls, before + 1);
    });
  });

  group('permission', () {
    testWidgets('ensurePermission requests, then registers the token', (
      tester,
    ) async {
      final h = (await tester.runAsync(_Harness.create))!;
      await tester.runAsync(() async {
        await h.service.initialize();
        await h.signIn();
        await h.settle();
      });
      expect(h.registrar.registrations.length, 1);
      h.registrar.registrations.clear();
      h.push.currentToken = 'token-9';
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );

      final state = await tester.runAsync(
        () => h.service.ensurePermission(context),
      );

      expect(state, NotificationPermissionState.granted);
      expect(h.permission.requests, 1);
      expect(h.push.permissionRequests, [false]);
      expect(h.registrar.registrations.single.token, 'token-9');
    });

    testWidgets('setEnabled(true) stays off when the user declines', (
      tester,
    ) async {
      final h = (await tester.runAsync(_Harness.create))!;
      h.permission.requestResult = NotificationPermissionState.denied;
      await tester.runAsync(() => h.service.setEnabled(enabled: false));
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );

      final turnedOn = await tester.runAsync(
        () => h.service.setEnabled(enabled: true, context: context),
      );

      expect(turnedOn, isFalse);
      expect(h.prefs.notificationsEnabled, isFalse);
    });

    test('permissionState reads the OS state without prompting', () async {
      final h = await _Harness.create();
      h.permission.state = NotificationPermissionState.permanentlyDenied;

      expect(
        await h.container.read(notificationPermissionStateProvider.future),
        NotificationPermissionState.permanentlyDenied,
      );
      expect(h.permission.requests, 0);
    });

    test(
      'provisional permission needs push and asks without a prompt',
      () async {
        final h = await _Harness.create();
        await h.service.initialize();
        h.push.permissionState = NotificationPermissionState.provisional;

        final state = await h.service.requestProvisionalPermission();

        expect(state, NotificationPermissionState.provisional);
        expect(h.push.permissionRequests.first, isTrue);
      },
    );

    test('opening the system settings is forwarded', () async {
      final h = await _Harness.create();

      await h.service.openSystemSettings();

      expect(h.permission.settingsOpened, 1);
    });
  });
}
