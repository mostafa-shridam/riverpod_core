import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_pruner.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';

import '../../../helpers/helpers.dart';

void main() {
  late CacheStore store;
  late DateTime now;

  setUp(() async {
    // Temp-dir Hive, so the pruner runs against files as it does in the app.
    final path = await testStoragePath();
    final storage = await openTestStorage(path: path);
    store = CacheStore(storage.cache);
    now = DateTime.utc(2026, 10, 17, 12);
  });

  Future<void> write(
    String key, {
    required DateTime savedAt,
    CachePolicy policy = CachePolicy.medium,
    DateTime? accessedAt,
  }) async {
    await store.write(key: key, payload: key, savedAt: savedAt, policy: policy);
    if (accessedAt != null) {
      await store.touch(key, accessedAt);
    }
  }

  group('CachePolicy', () {
    test('presets step from minutes to weeks (D-038)', () {
      expect(CachePolicy.short.ttl, const Duration(minutes: 5));
      expect(CachePolicy.medium.ttl, const Duration(hours: 1));
      expect(CachePolicy.long.ttl, const Duration(days: 1));
      expect(CachePolicy.static.ttl, const Duration(days: 7));
      expect(CachePolicy.static.maxAge, const Duration(days: 90));
    });
  });

  group('CachePruner', () {
    test('removes entries past their own maxAge and keeps the rest', () async {
      await write(
        'old',
        savedAt: now.subtract(const Duration(days: 2)),
        policy: CachePolicy.short,
      );
      await write('recent', savedAt: now.subtract(const Duration(days: 2)));

      final result = await CachePruner(store, clock: () => now).prune();

      expect(result.expired, 1);
      expect(store.read('old'), isNull, reason: 'short maxAge is one day');
      expect(
        store.read('recent'),
        isNotNull,
        reason: 'medium maxAge is 7 days',
      );
    });

    test('over the cap, evicts the least recently accessed first', () async {
      await write(
        'a',
        savedAt: now,
        accessedAt: now.add(const Duration(minutes: 3)),
      );
      await write(
        'b',
        savedAt: now,
        accessedAt: now.add(const Duration(minutes: 1)),
      );
      await write(
        'c',
        savedAt: now,
        accessedAt: now.add(const Duration(minutes: 2)),
      );

      final result = await CachePruner(
        store,
        clock: () => now,
        maxEntries: 2,
      ).prune();

      expect(result.evicted, 1);
      expect(store.read('b'), isNull, reason: 'accessed longest ago');
      expect(store.read('a'), isNotNull);
      expect(store.read('c'), isNotNull);
    });

    test(
      'expired entries go first, so the cap counts only live ones',
      () async {
        await write(
          'expired',
          savedAt: now.subtract(const Duration(days: 2)),
          policy: CachePolicy.short,
        );
        await write('live', savedAt: now);

        final result = await CachePruner(
          store,
          clock: () => now,
          maxEntries: 1,
        ).prune();

        expect(result, (expired: 1, evicted: 0));
        expect(store.read('live'), isNotNull);
      },
    );

    test('a box within the cap is left alone', () async {
      await write('a', savedAt: now);

      final result = await CachePruner(store, clock: () => now).prune();

      expect(result, (expired: 0, evicted: 0));
      expect(store.length, 1);
    });

    test('an empty box prunes to nothing', () async {
      final result = await CachePruner(store, clock: () => now).prune();
      expect(result, (expired: 0, evicted: 0));
      expect(Hive.isBoxOpen(HiveBoxNames.cache), isTrue);
    });
  });

  group('CacheStore.revalidate', () {
    test('moves the retention fields and keeps the payload', () async {
      await write('k', savedAt: now.subtract(const Duration(days: 1)));

      await store.revalidate(
        'k',
        savedAt: now,
        policy: CachePolicy.long,
        etag: 'e2',
      );

      final entry = store.read('k')!;
      expect(entry.payload, 'k');
      expect(entry.savedAt, now);
      expect(entry.ttl, CachePolicy.long.ttl);
      expect(entry.maxAge, CachePolicy.long.maxAge);
      expect(entry.etag, 'e2');
    });
  });
}
