import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_result.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';

part 'cached_repository_helper.g.dart';

/// A network fetch result: the value and the ETag the server sent, if any.
typedef CacheFetch<T> = ({T value, String? etag});

/// Stale-while-revalidate over the local [CacheStore] (STATE_AND_DATA.md).
///
/// Repositories call [watch] for data that should show at once and refresh in
/// the background. Concurrent watchers of one key share one fetch. Every cache
/// hit records its access time for least-recently-accessed pruning (D-038).
class CachedRepositoryHelper {
  CachedRepositoryHelper(this._store, {Clock? clock, AppLogger? logger})
    : _clock = clock ?? DateTime.now,
      _logger = logger ?? const AppLogger(level: LogLevel.warning);

  final CacheStore _store;
  final Clock _clock;
  final AppLogger _logger;

  /// Fetches shared by storage key while they run.
  final _inFlight = <String, Future<Object?>>{};

  /// Bumped by [invalidate], so a fetch that started earlier does not write
  /// its now-outdated value back.
  final _versions = <String, int>{};

  /// Emits the cached value at once (flagged stale when expired), then the
  /// fetched value. If the fetch fails, a cached value is emitted as stale with
  /// the error; with no cache, the stream errors with the mapped [AppException].
  Stream<CacheResult<T>> watch<T>({
    required String key,
    String? userId,
    required Future<CacheFetch<T>> Function() fetch,
    required T Function(String payload) decode,
    required String Function(T value) encode,
    required Duration ttl,
    Duration maxAge = defaultMaxAge,
  }) async* {
    final storageKey = cacheKey(key, userId: userId);
    final cached = await _readEntry(storageKey, decode);
    if (cached != null) {
      yield CacheResult(
        data: cached.value,
        isStale: isExpired(savedAt: cached.savedAt, ttl: ttl, now: _clock()),
        savedAt: cached.savedAt,
      );
    }

    final CacheResult<T> fresh;
    try {
      fresh = await _fetchShared(
        storageKey,
        fetch: fetch,
        encode: encode,
        ttl: ttl,
        maxAge: maxAge,
      );
    } catch (error, stack) {
      final exception = mapError(error, stack);
      if (cached == null) {
        throw exception;
      }
      yield CacheResult(
        data: cached.value,
        isStale: true,
        savedAt: cached.savedAt,
        error: exception,
      );
      return;
    }
    yield fresh;
  }

  /// One-shot read of the cached value, or null on a miss. Never fetches.
  Future<CacheResult<T>?> read<T>({
    required String key,
    String? userId,
    required T Function(String payload) decode,
    required Duration ttl,
  }) async {
    final cached = await _readEntry(cacheKey(key, userId: userId), decode);
    if (cached == null) {
      return null;
    }
    return CacheResult(
      data: cached.value,
      isStale: isExpired(savedAt: cached.savedAt, ttl: ttl, now: _clock()),
      savedAt: cached.savedAt,
    );
  }

  /// Removes one entry. A fetch still running for it will not write its value.
  Future<void> invalidate(String key, {String? userId}) async {
    final storageKey = cacheKey(key, userId: userId);
    _versions[storageKey] = (_versions[storageKey] ?? 0) + 1;
    _inFlight.remove(storageKey)?.ignore();
    await _store.delete(storageKey);
  }

  /// Removes every entry, for example on logout.
  Future<void> clearAll() async {
    _versions.updateAll((_, version) => version + 1);
    _inFlight.clear();
    await _store.clear();
  }

  Future<CacheResult<T>> _fetchShared<T>(
    String storageKey, {
    required Future<CacheFetch<T>> Function() fetch,
    required String Function(T value) encode,
    required Duration ttl,
    required Duration maxAge,
  }) {
    final running = _inFlight[storageKey];
    if (running != null) {
      return running.then((value) => value! as CacheResult<T>);
    }
    final future = _fetchAndStore(
      storageKey,
      fetch: fetch,
      encode: encode,
      ttl: ttl,
      maxAge: maxAge,
    );
    _inFlight[storageKey] = future;
    return future.whenComplete(() => _inFlight.remove(storageKey));
  }

  Future<CacheResult<T>> _fetchAndStore<T>(
    String storageKey, {
    required Future<CacheFetch<T>> Function() fetch,
    required String Function(T value) encode,
    required Duration ttl,
    required Duration maxAge,
  }) async {
    final version = _versions[storageKey] ?? 0;
    final fetched = await fetch();
    final savedAt = _clock();
    if ((_versions[storageKey] ?? 0) == version) {
      try {
        await _store.write(
          key: storageKey,
          payload: encode(fetched.value),
          savedAt: savedAt,
          etag: fetched.etag,
          ttl: ttl,
          maxAge: maxAge,
        );
      } catch (error, stack) {
        // The fresh value is still correct for this session; only the cache write failed.
        _logger.error(
          'Cache write failed for $storageKey',
          error: error,
          stackTrace: stack,
        );
      }
    }
    return CacheResult(data: fetched.value, isStale: false, savedAt: savedAt);
  }

  /// Reads and decodes an entry. An unreadable entry is removed and treated as
  /// a miss, so one bad row cannot break the screen. A hit records its access.
  Future<({T value, DateTime savedAt})?> _readEntry<T>(
    String storageKey,
    T Function(String payload) decode,
  ) async {
    final T value;
    final DateTime savedAt;
    try {
      final entry = _store.read(storageKey);
      if (entry == null) {
        return null;
      }
      value = decode(entry.payload);
      savedAt = entry.savedAt;
    } catch (error, stack) {
      _logger.warning(
        'Dropping unreadable cache entry $storageKey',
        error: error,
        stackTrace: stack,
      );
      await _store.delete(storageKey);
      return null;
    }
    await _recordAccess(storageKey);
    return (value: value, savedAt: savedAt);
  }

  /// Records a cache hit. A failure here only loses pruning accuracy, so it is
  /// logged and the read still succeeds.
  Future<void> _recordAccess(String storageKey) async {
    try {
      await _store.touch(storageKey, _clock());
    } catch (error, stack) {
      _logger.warning(
        'Could not record access to $storageKey',
        error: error,
        stackTrace: stack,
      );
    }
  }
}

/// The helper for the whole app, backed by the one [CacheStore].
@Riverpod(keepAlive: true)
CachedRepositoryHelper cachedRepositoryHelper(Ref ref) =>
    CachedRepositoryHelper(
      ref.watch(cacheStoreProvider),
      logger: ref.watch(loggerProvider),
    );
