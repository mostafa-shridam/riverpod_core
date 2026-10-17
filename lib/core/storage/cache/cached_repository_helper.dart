import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_result.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';

part 'cached_repository_helper.g.dart';

/// A network fetch result: the value and the ETag the server sent, if any.
/// A null [value] means the server answered "not modified" (304) to the ETag
/// it was sent, so the stored copy still stands.
typedef CacheFetch<T> = ({T? value, String? etag});

/// Runs one network fetch. Receives the ETag of the stored copy, if any, so the
/// server can answer 304 when nothing changed (D-038).
typedef CacheFetcher<T> = Future<CacheFetch<T>> Function(String? etag);

/// One finished fetch: the result to emit, and whether the data changed.
typedef _Fetched<T> = ({CacheResult<T> result, bool changed});

/// Stale-while-revalidate over the local [CacheStore] (STATE_AND_DATA.md).
///
/// Repositories call [watch] for data that should show at once and refresh in
/// the background. Concurrent watchers of one key share one fetch. An unchanged
/// answer (304, or the same payload) keeps the stored copy and emits nothing
/// new, except to clear a stale flag. Every cache hit records its access time
/// for least-recently-accessed pruning (D-038).
class CachedRepositoryHelper {
  CachedRepositoryHelper(this._store, {Clock? clock, AppLogger? logger})
    : _clock = clock ?? DateTime.now,
      _logger = logger ?? const AppLogger(level: LogLevel.warning);

  final CacheStore _store;
  final Clock _clock;
  final AppLogger _logger;

  /// Fetches shared by storage key while they run.
  final _inFlight = <String, Future<Object>>{};

  /// Bumped by [invalidate], so a fetch that started earlier does not write
  /// its now-outdated value back.
  final _versions = <String, int>{};

  /// Emits the cached value at once (flagged stale when older than the
  /// policy's ttl), then the fetched value when it differs. If the fetch fails,
  /// a cached value is emitted as stale with the error; with no cache, the
  /// stream errors with the mapped [AppException].
  Stream<CacheResult<T>> watch<T>({
    required String key,
    String? userId,
    required CacheFetcher<T> fetch,
    required T Function(String payload) decode,
    required String Function(T value) encode,
    CachePolicy policy = CachePolicy.medium,
  }) async* {
    final storageKey = cacheKey(key, userId: userId);
    final cached = await _readEntry(storageKey, decode);
    final cachedStale =
        cached != null &&
        isExpired(savedAt: cached.savedAt, ttl: policy.ttl, now: _clock());
    if (cached != null) {
      yield CacheResult(
        data: cached.value,
        isStale: cachedStale,
        savedAt: cached.savedAt,
      );
    }

    final _Fetched<T> fetched;
    try {
      fetched = await _fetchShared(
        storageKey,
        fetch: fetch,
        decode: decode,
        encode: encode,
        policy: policy,
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
    // An unchanged copy is already on screen. Only a stale one needs a new
    // result, to clear its stale flag.
    if (fetched.changed || cachedStale) {
      yield fetched.result;
    }
  }

  /// The one call a repository makes (D-038), as a Future of the data.
  ///
  /// Cache-first by default: the cached value comes back at once, and the
  /// revalidation finishes in the background so the next read is fresh. With no
  /// cache this waits for the network. With [fresh] (refresh and reload) it
  /// waits for the network and returns that answer; a failure is raised even
  /// when a cached copy exists, so the page can show the error beside the data.
  Future<T> load<T>({
    required String key,
    String? userId,
    required CacheFetcher<T> fetch,
    required T Function(String payload) decode,
    required String Function(T value) encode,
    CachePolicy policy = CachePolicy.medium,
    bool fresh = false,
  }) async {
    final storageKey = cacheKey(key, userId: userId);
    if (fresh) {
      // Waits for the network directly; a failure is raised even with a cache.
      try {
        final fetched = await _fetchShared(
          storageKey,
          fetch: fetch,
          decode: decode,
          encode: encode,
          policy: policy,
        );
        return fetched.result.data;
      } catch (error, stack) {
        throw mapError(error, stack);
      }
    }
    final updates = StreamIterator(
      watch<T>(
        key: key,
        userId: userId,
        fetch: fetch,
        decode: decode,
        encode: encode,
        policy: policy,
      ),
    );
    if (!await updates.moveNext()) {
      await updates.cancel();
      throw StateError('The cache stream ended without a value.');
    }
    final first = updates.current.data;
    unawaited(_drain(updates));
    return first;
  }

  /// Runs the rest of a [load] stream to its end, so the background
  /// revalidation completes. Its failures were already logged or returned.
  Future<void> _drain<T>(StreamIterator<CacheResult<T>> updates) async {
    try {
      while (await updates.moveNext()) {}
    } on Object {
      // Nothing to show: the first value was already returned.
    } finally {
      await updates.cancel();
    }
  }

  /// One-shot read of the cached value, or null on a miss. Never fetches.
  Future<CacheResult<T>?> read<T>({
    required String key,
    String? userId,
    required T Function(String payload) decode,
    CachePolicy policy = CachePolicy.medium,
  }) async {
    final cached = await _readEntry(cacheKey(key, userId: userId), decode);
    if (cached == null) {
      return null;
    }
    return CacheResult(
      data: cached.value,
      isStale: isExpired(
        savedAt: cached.savedAt,
        ttl: policy.ttl,
        now: _clock(),
      ),
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

  Future<_Fetched<T>> _fetchShared<T>(
    String storageKey, {
    required CacheFetcher<T> fetch,
    required T Function(String payload) decode,
    required String Function(T value) encode,
    required CachePolicy policy,
  }) {
    final running = _inFlight[storageKey];
    if (running != null) {
      return running.then((value) => value as _Fetched<T>);
    }
    final future = _fetchAndStore(
      storageKey,
      fetch: fetch,
      decode: decode,
      encode: encode,
      policy: policy,
    );
    _inFlight[storageKey] = future;
    return future.whenComplete(() => _inFlight.remove(storageKey));
  }

  Future<_Fetched<T>> _fetchAndStore<T>(
    String storageKey, {
    required CacheFetcher<T> fetch,
    required T Function(String payload) decode,
    required String Function(T value) encode,
    required CachePolicy policy,
  }) async {
    final version = _versions[storageKey] ?? 0;
    final previous = _storedEntry(storageKey);
    final fetched = await fetch(previous?.etag);
    final savedAt = _clock();
    final current = (_versions[storageKey] ?? 0) == version;

    final value = fetched.value;
    if (value == null) {
      // 304: the stored copy still matches the server.
      if (previous == null) {
        throw StateError('Not modified without a cached copy: $storageKey');
      }
      if (current) {
        await _revalidate(storageKey, savedAt, policy, fetched.etag);
      }
      return (
        result: CacheResult(
          data: decode(previous.payload),
          isStale: false,
          savedAt: savedAt,
        ),
        changed: false,
      );
    }

    final payload = encode(value);
    if (previous != null && previous.payload == payload) {
      // Same payload under a new response: keep it, move only the retention data.
      if (current) {
        await _revalidate(storageKey, savedAt, policy, fetched.etag);
      }
      return (
        result: CacheResult(data: value, isStale: false, savedAt: savedAt),
        changed: false,
      );
    }

    if (current) {
      try {
        await _store.write(
          key: storageKey,
          payload: payload,
          savedAt: savedAt,
          etag: fetched.etag,
          policy: policy,
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
    return (
      result: CacheResult(data: value, isStale: false, savedAt: savedAt),
      changed: true,
    );
  }

  /// Moves the retention fields of a confirmed copy. A failure only leaves the
  /// copy looking older than it is, so it is logged and the read still succeeds.
  Future<void> _revalidate(
    String storageKey,
    DateTime savedAt,
    CachePolicy policy,
    String? etag,
  ) async {
    try {
      await _store.revalidate(
        storageKey,
        savedAt: savedAt,
        policy: policy,
        etag: etag,
      );
    } catch (error, stack) {
      _logger.warning(
        'Could not revalidate $storageKey',
        error: error,
        stackTrace: stack,
      );
    }
  }

  /// The stored entry, or null when missing or unreadable. Used to send the
  /// ETag and to compare payloads, so an unreadable row counts as missing.
  CacheEntry? _storedEntry(String storageKey) {
    try {
      return _store.read(storageKey);
    } catch (error, stack) {
      _logger.warning(
        'Ignoring unreadable cache entry $storageKey',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
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
