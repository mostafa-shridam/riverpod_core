import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';

import '../../helpers/helpers.dart';

void main() {
  late CacheStore store;

  setUp(() async {
    store = await fakeCacheStore();
  });

  final saved = DateTime.utc(2026, 10, 16, 12);

  test('insert then read returns the same payload and etag', () async {
    await store.write(
      key: 'products',
      payload: '[1,2]',
      savedAt: saved,
      etag: 'W/"abc"',
    );
    final entry = store.read('products');
    expect(entry, isNotNull);
    expect(entry!.payload, '[1,2]');
    expect(entry.etag, 'W/"abc"');
    expect(entry.savedAt, saved);
  });

  test('writing the same key replaces the entry', () async {
    await store.write(key: 'k', payload: 'old', savedAt: saved);
    await store.write(key: 'k', payload: 'new', savedAt: saved);
    expect(store.read('k')!.payload, 'new');
  });

  test('missing key reads as null', () {
    expect(store.read('nope'), isNull);
  });

  test('deleteSavedBefore expires only older entries', () async {
    await store.write(
      key: 'old',
      payload: '1',
      savedAt: saved.subtract(const Duration(hours: 2)),
    );
    await store.write(key: 'fresh', payload: '2', savedAt: saved);

    final removed = await store.deleteSavedBefore(
      saved.subtract(const Duration(hours: 1)),
    );

    expect(removed, 1);
    expect(store.read('old'), isNull);
    expect(store.read('fresh'), isNotNull);
  });

  test('delete removes one key', () async {
    await store.write(key: 'a', payload: '1', savedAt: saved);
    await store.write(key: 'b', payload: '2', savedAt: saved);
    await store.delete('a');
    expect(store.read('a'), isNull);
    expect(store.read('b'), isNotNull);
  });

  test('clear empties the box', () async {
    await store.write(key: 'a', payload: '1', savedAt: saved);
    await store.write(key: 'b', payload: '2', savedAt: saved);
    await store.clear();
    expect(store.read('a'), isNull);
    expect(store.read('b'), isNull);
  });

  test('entries survive closing and reopening the box', () async {
    final path = await testStoragePath();
    final first = await openTestStorage(path: path);
    await CacheStore(
      first.cache,
    ).write(key: 'k', payload: '[9]', savedAt: saved, etag: 'e1');
    await Hive.close();

    final reopened = await openTestStorage(path: path);
    final entry = CacheStore(reopened.cache).read('k');
    expect(entry!.payload, '[9]');
    expect(entry.etag, 'e1');
    expect(entry.savedAt, saved);
  });

  test(
    'write keeps ttl and maxAge and starts with lastAccessedAt = savedAt',
    () async {
      await store.write(
        key: 'k',
        payload: '1',
        savedAt: saved,
        policy: const CachePolicy(
          ttl: Duration(minutes: 5),
          maxAge: Duration(days: 7),
        ),
      );
      final entry = store.read('k')!;
      expect(entry.ttl, const Duration(minutes: 5));
      expect(entry.maxAge, const Duration(days: 7));
      expect(entry.lastAccessedAt, saved);
    },
  );

  test('touch records a later access and keeps the payload', () async {
    await store.write(key: 'k', payload: 'v', savedAt: saved, etag: 'e');
    final later = saved.add(const Duration(hours: 3));

    await store.touch('k', later);

    final entry = store.read('k')!;
    expect(entry.lastAccessedAt, later);
    expect(entry.savedAt, saved);
    expect(entry.payload, 'v');
    expect(entry.etag, 'e');
  });

  test('touch on a missing key does nothing', () async {
    await store.touch('missing', saved);
    expect(store.read('missing'), isNull);
    expect(store.length, 0);
  });

  test(
    'keysSavedBefore lists old entries, oldest first, without deleting',
    () async {
      await store.write(
        key: 'b',
        payload: '1',
        savedAt: saved.subtract(const Duration(hours: 2)),
      );
      await store.write(
        key: 'a',
        payload: '2',
        savedAt: saved.subtract(const Duration(hours: 3)),
      );
      await store.write(key: 'new', payload: '3', savedAt: saved);

      expect(store.keysSavedBefore(saved.subtract(const Duration(hours: 1))), [
        'a',
        'b',
      ]);
      expect(store.length, 3);
    },
  );

  test(
    'keysLeastRecentlyAccessed lists the least recently read first, with a limit',
    () async {
      await store.write(key: 'a', payload: '1', savedAt: saved);
      await store.write(key: 'b', payload: '2', savedAt: saved);
      await store.write(key: 'c', payload: '3', savedAt: saved);
      await store.touch('a', saved.add(const Duration(hours: 2)));
      await store.touch('c', saved.add(const Duration(hours: 1)));

      expect(store.keysLeastRecentlyAccessed(limit: 2), ['b', 'c']);
      expect(store.keysLeastRecentlyAccessed(limit: 10), ['b', 'c', 'a']);
    },
  );

  test(
    'deleteLeastRecentlyAccessed removes the oldest accessed entries',
    () async {
      await store.write(key: 'a', payload: '1', savedAt: saved);
      await store.write(key: 'b', payload: '2', savedAt: saved);
      await store.touch('a', saved.add(const Duration(hours: 1)));

      final removed = await store.deleteLeastRecentlyAccessed(1);

      expect(removed, 1);
      expect(store.read('b'), isNull);
      expect(store.read('a'), isNotNull);
    },
  );

  test(
    'entries written before the retention fields read with defaults',
    () async {
      final storage = await openTestStorage();
      await storage.cache.put('legacy', {
        'payload': 'old',
        'savedAt': saved.millisecondsSinceEpoch,
        'etag': null,
      });

      final entry = CacheStore(storage.cache).read('legacy')!;

      expect(entry.payload, 'old');
      expect(entry.lastAccessedAt, saved);
      expect(entry.maxAge, CachePolicy.medium.maxAge);
    },
  );
}
