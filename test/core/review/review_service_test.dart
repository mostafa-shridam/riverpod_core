import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/review/review_service.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/fake_native_backends.dart';
import '../../helpers/helpers.dart';

void main() {
  late DateTime now;
  late FakeReviewBackend backend;
  late PrefsStorage prefs;

  Future<ReviewService> build({
    Duration interval = const Duration(days: 30),
    String? storeId,
    Map<String, Object> initial = const {},
  }) async {
    prefs = await fakePrefsStorage(initial);
    return ReviewService(
      backend: backend,
      prefs: prefs,
      now: () => now,
      minInterval: interval,
      appStoreId: storeId,
    );
  }

  setUp(() {
    now = DateTime.utc(2026, 1, 1);
    backend = FakeReviewBackend();
  });

  test('the first call shows the in-app prompt and stores the time', () async {
    final service = await build();

    expect(service.canAsk, isTrue);
    expect(await service.maybeAskForReview(), isTrue);

    expect(backend.requestCalls, 1);
    expect(prefs.getStringList(reviewLastAskedKey), [
      '2026-01-01T00:00:00.000Z',
    ]);
  });

  test('a second call inside the interval does nothing', () async {
    final service = await build();
    await service.maybeAskForReview();

    now = now.add(const Duration(days: 29, hours: 23));

    expect(service.canAsk, isFalse);
    expect(await service.maybeAskForReview(), isFalse);
    expect(backend.requestCalls, 1);
  });

  test('exactly at the interval it asks again', () async {
    final service = await build();
    await service.maybeAskForReview();

    now = now.add(const Duration(days: 30));

    expect(service.canAsk, isTrue);
    expect(await service.maybeAskForReview(), isTrue);
    expect(backend.requestCalls, 2);
  });

  test('the throttle survives a new service instance (prefs)', () async {
    final first = await build();
    await first.maybeAskForReview();
    final stored = prefs.getStringList(reviewLastAskedKey).first;

    final second = await build(
      initial: {
        reviewLastAskedKey: [stored],
      },
    );

    expect(second.canAsk, isFalse);
  });

  test('falls back to the store listing when no in-app prompt', () async {
    backend.available = false;
    final service = await build(storeId: '12345');

    expect(await service.maybeAskForReview(), isTrue);

    expect(backend.requestCalls, 0);
    expect(backend.storeListingCalls, ['12345']);
    expect(prefs.getStringList(reviewLastAskedKey), isNotEmpty);
  });

  test('a platform error is false and does not start the interval', () async {
    backend.error = StateError('boom');
    final service = await build();

    expect(await service.maybeAskForReview(), isFalse);
    expect(prefs.getStringList(reviewLastAskedKey), isEmpty);

    backend.error = null;
    expect(await service.maybeAskForReview(), isTrue);
  });

  test('an unreadable stored time counts as never asked', () async {
    final service = await build(
      initial: {
        reviewLastAskedKey: ['garbage'],
      },
    );

    expect(service.canAsk, isTrue);
  });

  test('openStoreListing is not throttled and reports errors', () async {
    final service = await build(storeId: '9');
    await service.maybeAskForReview();

    expect(await service.openStoreListing(), isTrue);
    expect(backend.storeListingCalls, ['9']);

    backend.error = StateError('boom');
    expect(await service.openStoreListing(), isFalse);
  });

  test('the key is a device setting that survives logout', () async {
    final service = await build();
    await service.maybeAskForReview();
    await prefs.clearUserScoped();

    expect(reviewLastAskedKey.startsWith(PrefKeys.userPrefix), isFalse);
    expect(service.canAsk, isFalse);
  });

  test('provider wires backend, prefs, clock and store id', () async {
    final prefs = await fakePrefsStorage();
    final container = createContainer(
      overrides: [
        reviewBackendProvider.overrideWithValue(backend),
        reviewClockProvider.overrideWithValue(() => now),
        appStoreIdProvider.overrideWithValue('77'),
        prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      ],
    );

    final service = await container.read(reviewServiceProvider.future);
    backend.available = false;
    await service.maybeAskForReview();

    expect(backend.storeListingCalls, ['77']);
  });
}
