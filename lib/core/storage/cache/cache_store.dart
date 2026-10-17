import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';

part 'cache_store.g.dart';

/// One cached payload with its retention data (D-038).
class CacheEntry {
  const CacheEntry({
    required this.payload,
    required this.savedAt,
    required this.lastAccessedAt,
    required this.ttl,
    required this.maxAge,
    this.etag,
  });

  final String payload;

  /// When the payload was fetched. UTC.
  final DateTime savedAt;

  /// When the entry was last read. Drives least-recently-accessed pruning. UTC.
  final DateTime lastAccessedAt;

  /// How long the payload counts as fresh.
  final Duration ttl;

  /// How long the entry may be kept before pruning.
  final Duration maxAge;
  final String? etag;
}

/// Stale-while-revalidate cache on a Hive box (D-034). One map per key:
/// `{payload, savedAt, lastAccessedAt, ttl, maxAge, etag?}`, times in ms since
/// epoch (UTC) and durations in ms.
class CacheStore {
  CacheStore(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// Number of entries in the box.
  int get length => _box.length;

  /// The entry for [key], or null. Throws when the stored value has an
  /// unexpected shape; callers treat that as a miss. Entries written before
  /// D-038 lack the retention fields and read with defaults.
  CacheEntry? read(String key) {
    final raw = _box.get(key);
    if (raw == null) {
      return null;
    }
    final savedAt = _time(raw['savedAt'] as int);
    return CacheEntry(
      payload: raw['payload'] as String,
      savedAt: savedAt,
      lastAccessedAt: raw['lastAccessedAt'] == null
          ? savedAt
          : _time(raw['lastAccessedAt'] as int),
      ttl: raw['ttl'] == null
          ? defaultMaxAge
          : Duration(milliseconds: raw['ttl'] as int),
      maxAge: raw['maxAge'] == null
          ? defaultMaxAge
          : Duration(milliseconds: raw['maxAge'] as int),
      etag: raw['etag'] as String?,
    );
  }

  /// Inserts or replaces the entry for [key]. The last access is [savedAt].
  Future<void> write({
    required String key,
    required String payload,
    required DateTime savedAt,
    String? etag,
    Duration ttl = const Duration(hours: 1),
    Duration maxAge = defaultMaxAge,
  }) => _box.put(key, {
    'payload': payload,
    'savedAt': savedAt.toUtc().millisecondsSinceEpoch,
    'lastAccessedAt': savedAt.toUtc().millisecondsSinceEpoch,
    'ttl': ttl.inMilliseconds,
    'maxAge': maxAge.inMilliseconds,
    'etag': etag,
  });

  /// Records a read of [key] at [at]. Missing keys are ignored.
  Future<void> touch(String key, DateTime at) async {
    final raw = _box.get(key);
    if (raw == null) {
      return;
    }
    await _box.put(key, {
      ...raw,
      'lastAccessedAt': at.toUtc().millisecondsSinceEpoch,
    });
  }

  Future<void> delete(String key) => _box.delete(key);

  /// Keys of entries saved before [cutoff], oldest first.
  List<String> keysSavedBefore(DateTime cutoff) {
    final limit = cutoff.toUtc().millisecondsSinceEpoch;
    final keys = [
      for (final key in _box.keys)
        if (((_box.get(key)?['savedAt'] as int?) ?? 0) < limit) key as String,
    ];
    keys.sort(
      (a, b) => (_box.get(a)!['savedAt'] as int).compareTo(
        _box.get(b)!['savedAt'] as int,
      ),
    );
    return keys;
  }

  /// Removes entries saved before [cutoff]. Returns how many were removed.
  Future<int> deleteSavedBefore(DateTime cutoff) async {
    final keys = keysSavedBefore(cutoff);
    await _box.deleteAll(keys);
    return keys.length;
  }

  /// Up to [limit] keys, least recently accessed first.
  List<String> keysLeastRecentlyAccessed({required int limit}) {
    final keys = [for (final key in _box.keys) key as String]
      ..sort((a, b) => _lastAccessed(a).compareTo(_lastAccessed(b)));
    return keys.take(limit).toList();
  }

  /// Removes the [count] least recently accessed entries. Returns how many were removed.
  Future<int> deleteLeastRecentlyAccessed(int count) async {
    final keys = keysLeastRecentlyAccessed(limit: count);
    await _box.deleteAll(keys);
    return keys.length;
  }

  Future<void> clear() async {
    await _box.clear();
  }

  int _lastAccessed(String key) {
    final raw = _box.get(key)!;
    return (raw['lastAccessedAt'] ?? raw['savedAt']) as int;
  }

  DateTime _time(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

/// The cache store for the whole app, on the box bootstrap opened.
@Riverpod(keepAlive: true)
CacheStore cacheStore(Ref ref) => CacheStore(ref.watch(cacheBoxProvider));
