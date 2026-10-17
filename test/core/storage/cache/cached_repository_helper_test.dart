import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_result.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

import '../../../helpers/helpers.dart';

const _ttl = Duration(minutes: 5);

String _encode(int value) => '$value';
int _decode(String payload) => int.parse(payload);

CacheFetch<int> _ok(int value, {String? etag}) => (value: value, etag: etag);

Matcher _result(int data, {bool isStale = false, Matcher? error}) =>
    isA<CacheResult<int>>()
        .having((r) => r.data, 'data', data)
        .having((r) => r.isStale, 'isStale', isStale)
        .having((r) => r.error, 'error', error ?? isNull);

void main() {
  late CacheStore store;
  late DateTime now;
  late CachedRepositoryHelper helper;

  setUp(() async {
    store = await fakeCacheStore();
    now = DateTime.utc(2026, 10, 16, 12);
    helper = CachedRepositoryHelper(store, clock: () => now);
  });

  Stream<CacheResult<int>> watchInt({
    String key = 'k',
    String? userId,
    required Future<CacheFetch<int>> Function() fetch,
  }) => helper.watch<int>(
    key: key,
    userId: userId,
    fetch: fetch,
    decode: _decode,
    encode: _encode,
    ttl: _ttl,
  );

  Future<void> seed(
    int value, {
    required DateTime savedAt,
    String key = 'k',
    String? userId,
  }) => store.write(
    key: cacheKey(key, userId: userId),
    payload: '$value',
    savedAt: savedAt,
  );

  group('CachedRepositoryHelper.watch', () {
    test('cache miss emits only the fetched value', () async {
      await expectLater(
        watchInt(fetch: () async => _ok(2)),
        emitsInOrder([_result(2), emitsDone]),
      );
    });

    test(
      'a fresh cache entry is emitted at once, then the fetch replaces it',
      () async {
        await seed(1, savedAt: now.subtract(const Duration(minutes: 1)));
        final gate = Completer<CacheFetch<int>>()..complete(_ok(2));

        await expectLater(
          watchInt(fetch: () => gate.future),
          emitsInOrder([_result(1), _result(2), emitsDone]),
        );
      },
    );

    test(
      'an expired cache entry is emitted as stale before the fetch',
      () async {
        await seed(1, savedAt: now.subtract(const Duration(minutes: 10)));

        await expectLater(
          watchInt(fetch: () async => _ok(2)),
          emitsInOrder([_result(1, isStale: true), _result(2), emitsDone]),
        );
      },
    );

    test(
      'a failed fetch with a cache emits the cached value as stale with the error',
      () async {
        await seed(1, savedAt: now);

        await expectLater(
          watchInt(fetch: () async => throw const NetworkException()),
          emitsInOrder([
            _result(1),
            _result(1, isStale: true, error: isA<NetworkException>()),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'a failed fetch without a cache errors with the mapped exception',
      () async {
        await expectLater(
          watchInt(fetch: () async => throw const NetworkException()),
          emitsError(isA<NetworkException>()),
        );
      },
    );

    test('unknown fetch errors are mapped to UnknownException', () async {
      await expectLater(
        watchInt(fetch: () async => throw StateError('boom')),
        emitsError(isA<UnknownException>()),
      );
    });

    test(
      'a successful fetch is written to the cache with its etag and time',
      () async {
        await expectLater(
          watchInt(fetch: () async => _ok(7, etag: 'W/"x"')),
          emitsInOrder([_result(7), emitsDone]),
        );

        final entry = store.read(cacheKey('k'));
        expect(entry, isNotNull);
        expect(entry!.payload, '7');
        expect(entry.etag, 'W/"x"');
        expect(entry.savedAt, now);
      },
    );

    test(
      'a cache entry that cannot be decoded is dropped and treated as a miss',
      () async {
        await store.write(
          key: cacheKey('k'),
          payload: 'not a number',
          savedAt: now,
        );

        await expectLater(
          watchInt(fetch: () async => _ok(3)),
          emitsInOrder([_result(3), emitsDone]),
        );
        expect((store.read(cacheKey('k')))!.payload, '3');
      },
    );

    test('concurrent watchers of one key share one fetch', () async {
      var fetches = 0;
      final gate = Completer<CacheFetch<int>>();
      Future<CacheFetch<int>> fetch() {
        fetches++;
        return gate.future;
      }

      final first = watchInt(fetch: fetch).toList();
      final second = watchInt(fetch: fetch).toList();
      await pumpEventQueue();
      gate.complete(_ok(5));
      final results = await Future.wait([first, second]);

      expect(fetches, 1);
      expect(results.map((r) => r.single.data), [5, 5]);
    });

    test(
      'a fetch that finishes after invalidate does not write its value',
      () async {
        final gate = Completer<CacheFetch<int>>();
        final pending = watchInt(fetch: () => gate.future).toList();
        await pumpEventQueue();

        await helper.invalidate('k');
        gate.complete(_ok(9));
        await pending;

        expect(store.read(cacheKey('k')), isNull);
      },
    );
  });

  group('CachedRepositoryHelper.read', () {
    test('returns null on a miss and never fetches', () async {
      expect(
        await helper.read<int>(key: 'k', decode: _decode, ttl: _ttl),
        isNull,
      );
    });

    test('returns the cached value with its freshness', () async {
      await seed(4, savedAt: now);
      final fresh = await helper.read<int>(
        key: 'k',
        decode: _decode,
        ttl: _ttl,
      );
      expect(fresh!.data, 4);
      expect(fresh.isStale, isFalse);

      await seed(4, savedAt: now.subtract(const Duration(hours: 1)));
      final stale = await helper.read<int>(
        key: 'k',
        decode: _decode,
        ttl: _ttl,
      );
      expect(stale!.isStale, isTrue);
    });
  });

  group('invalidate and clearAll', () {
    test('invalidate removes one entry', () async {
      await seed(1, savedAt: now);
      await seed(2, savedAt: now, key: 'other');

      await helper.invalidate('k');

      expect(store.read(cacheKey('k')), isNull);
      expect(store.read(cacheKey('other')), isNotNull);
    });

    test('clearAll removes every entry', () async {
      await seed(1, savedAt: now);
      await seed(2, savedAt: now, key: 'other');

      await helper.clearAll();

      expect(store.read(cacheKey('k')), isNull);
      expect(store.read(cacheKey('other')), isNull);
    });
  });

  group('user scoping', () {
    test('keys of different users are prefixed and independent', () async {
      expect(cacheKey('k', userId: 'a'), 'user/a/k');
      expect(cacheKey('k'), 'shared/k');

      await seed(1, savedAt: now, userId: 'a');
      await seed(2, savedAt: now, userId: 'b');

      await helper.invalidate('k', userId: 'a');

      expect(store.read(cacheKey('k', userId: 'a')), isNull);
      expect((store.read(cacheKey('k', userId: 'b')))!.payload, '2');
    });
  });

  test('a cache hit records the access time', () async {
    await store.write(
      key: cacheKey('k'),
      payload: '1',
      savedAt: now.subtract(const Duration(hours: 1)),
    );

    final results = await watchInt(
      fetch: () async => throw const NetworkException(),
    ).toList();
    expect(results.last.isStale, isTrue);

    expect(store.read(cacheKey('k'))!.lastAccessedAt, now);
  });
}
