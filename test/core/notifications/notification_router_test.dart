import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router.dart';
import 'package:riverpod_core/core/router/routes.dart';

import '../../helpers/fake_notification_backends.dart';

NotificationTap _tap(
  NotificationPayload payload, {
  NotificationTapSource source = NotificationTapSource.pushOpened,
  String? actionId,
}) => NotificationTap(payload: payload, source: source, actionId: actionId);

void main() {
  late List<GoRouteData> opened;
  late List<Uri> urls;
  late NotificationRouter router;

  setUp(() {
    opened = [];
    urls = [];
    router = NotificationRouter(
      resolver: routeForDeepLink,
      openUrl: (url) async => urls.add(url),
      logger: () => recordingLogger([]),
      maxQueued: 2,
    );
  });

  tearDown(() => router.dispose());

  void ready() {
    router
      ..attach(opened.add)
      ..setSessionReady(ready: true);
  }

  test('a known type opens its typed route', () {
    ready();

    router.handle(_tap(const NotificationPayload(type: 'myEvents', id: '42')));

    expect(opened, hasLength(1));
    expect((opened.single as ItemDetailRoute).id, '42');
  });

  test('every tap source goes through the same path', () {
    ready();

    for (final source in NotificationTapSource.values) {
      router.handle(
        _tap(
          const NotificationPayload(type: 'myEvents', id: '1'),
          source: source,
        ),
      );
    }

    expect(opened, hasLength(NotificationTapSource.values.length));
  });

  test('an unknown type is ignored', () {
    ready();

    router.handle(_tap(const NotificationPayload(type: 'nope', id: '1')));

    expect(opened, isEmpty);
    expect(urls, isEmpty);
  });

  test('an empty payload is ignored and not queued', () {
    router.handle(_tap(const NotificationPayload()));

    expect(router.queuedCount, 0);
  });

  test('taps are queued until the router is attached and signed in', () {
    router.handle(_tap(const NotificationPayload(type: 'myEvents', id: '1')));
    expect(router.queuedCount, 1);

    router.attach(opened.add);
    expect(opened, isEmpty, reason: 'attached but not signed in');

    router.setSessionReady(ready: true);
    expect(opened, hasLength(1));
    expect(router.queuedCount, 0);
  });

  test('queued taps replay in order', () {
    router
      ..handle(_tap(const NotificationPayload(type: 'myEvents', id: '1')))
      ..handle(_tap(const NotificationPayload(type: 'myEvents', id: '2')));

    ready();

    expect(opened.map((r) => (r as ItemDetailRoute).id), ['1', '2']);
  });

  test('the queue keeps only the newest taps', () {
    for (final id in ['1', '2', '3']) {
      router.handle(_tap(NotificationPayload(type: 'myEvents', id: id)));
    }

    ready();

    expect(opened.map((r) => (r as ItemDetailRoute).id), ['2', '3']);
  });

  test('losing the session queues again', () {
    ready();
    router.setSessionReady(ready: false);

    router.handle(_tap(const NotificationPayload(type: 'myEvents', id: '1')));

    expect(opened, isEmpty);
    expect(router.queuedCount, 1);
  });

  test('a url opens when there is no route', () async {
    ready();

    router.handle(
      _tap(const NotificationPayload(url: 'https://example.com/promo')),
    );
    await Future<void>.delayed(Duration.zero);

    expect(urls, [Uri.parse('https://example.com/promo')]);
  });

  test('only http and https urls are opened', () async {
    ready();

    for (final url in ['intent://x', 'tel:123', 'javascript:alert(1)', 'a b']) {
      router.handle(_tap(NotificationPayload(url: url)));
    }
    await Future<void>.delayed(Duration.zero);

    expect(urls, isEmpty);
  });

  test('a route wins over a url', () async {
    ready();

    router.handle(
      _tap(
        const NotificationPayload(
          type: 'myEvents',
          id: '9',
          url: 'https://example.com',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(opened, hasLength(1));
    expect(urls, isEmpty);
  });

  test('action presses go to the actions stream, never the queue', () async {
    final received = <NotificationTap>[];
    router.actions.listen(received.add);

    router.handle(
      _tap(
        const NotificationPayload(type: 'chat', id: '3'),
        actionId: 'reply',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(received.single.actionId, 'reply');
    expect(router.queuedCount, 0);
  });
}
