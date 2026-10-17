import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_repository.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

import '../../helpers/helpers.dart';

/// Serves [value], or throws [error] when set; counts the calls.
class _Source implements RemoteConfigSource {
  _Source({this.value, this.error});

  RemoteConfig? value;
  Object? error;
  int calls = 0;

  @override
  Future<CacheFetch<RemoteConfig>> fetch() async {
    calls++;
    if (error != null) throw error!;
    return (value: value!, etag: null);
  }
}

const _old = RemoteConfig(minVersion: '1.0.0', latestVersion: '1.0.0');
const _new = RemoteConfig(minVersion: '1.0.0', latestVersion: '1.5.0');

void main() {
  late CacheStore store;
  late DateTime now;
  late CachedRepositoryHelper helper;

  setUp(() async {
    store = await fakeCacheStore();
    now = DateTime.utc(2026, 1, 1, 12);
    helper = CachedRepositoryHelper(store, clock: () => now);
  });

  test('no cache: the fetched config is emitted once', () async {
    final source = _Source(value: _new);
    final events = await RemoteConfigRepository(
      helper,
      source,
    ).watch().toList();

    expect(events.map((e) => e.data), [_new]);
    expect(events.single.isStale, isFalse);
  });

  test('a cached copy is emitted first, then the fresh one', () async {
    final source = _Source(value: _old);
    await RemoteConfigRepository(helper, source).watch().toList();

    source.value = _new;
    final events = await RemoteConfigRepository(
      helper,
      source,
    ).watch().toList();

    expect(events.map((e) => e.data), [_old, _new]);
    expect(events.first.isStale, isFalse, reason: 'within its ttl');
    expect(events.last.isStale, isFalse);
  });

  test('a cached copy older than the ttl is emitted as stale', () async {
    final source = _Source(value: _old);
    await RemoteConfigRepository(helper, source).watch().toList();

    now = now.add(RemoteConfigRepository.ttl + const Duration(minutes: 1));
    source.error = const NetworkException();
    final events = await RemoteConfigRepository(
      helper,
      source,
    ).watch().toList();

    expect(events.first.data, _old);
    expect(events.first.isStale, isTrue);
  });

  test(
    'a failed fetch with a cache keeps the cached copy, marked stale',
    () async {
      final source = _Source(value: _old);
      await RemoteConfigRepository(helper, source).watch().toList();

      source.error = const NetworkException();
      final events = await RemoteConfigRepository(
        helper,
        source,
      ).watch().toList();

      final last = events.last;
      expect(last.data, _old);
      expect(last.isStale, isTrue);
      expect(last.error, isA<NetworkException>());
    },
  );

  test('a failed fetch with no cache errors the stream', () async {
    final source = _Source(error: const NetworkException());

    await expectLater(
      RemoteConfigRepository(helper, source).watch().toList(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('the stored copy round-trips every field', () async {
    const full = RemoteConfig(
      minVersion: '1.2.0',
      latestVersion: '1.3.0',
      storeUrl: 'https://store.example.test/app',
      maintenance: RemoteMaintenance(enabled: true, message: 'Back soon'),
      flags: {'newCheckout': true},
    );
    final source = _Source(value: full);
    await RemoteConfigRepository(helper, source).watch().toList();

    source.error = const NetworkException();
    final cached = await RemoteConfigRepository(helper, source).watch().last;

    expect(cached.data, full);
  });
}
