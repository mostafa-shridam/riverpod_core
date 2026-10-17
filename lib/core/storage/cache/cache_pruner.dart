import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';

part 'cache_pruner.g.dart';

/// What one prune removed: entries past their own maxAge, then the least
/// recently accessed entries over the cap.
typedef PruneResult = ({int expired, int evicted});

/// Keeps the cache bounded (D-038). Expired entries go first, then the least
/// recently accessed entries until the box is within [maxEntries].
class CachePruner {
  CachePruner(this._store, {Clock? clock, this.maxEntries = defaultMaxEntries})
    : _clock = clock ?? DateTime.now;

  /// Entry cap. Apps that cache more tune it here, in one place.
  static const defaultMaxEntries = 500;

  final CacheStore _store;
  final Clock _clock;
  final int maxEntries;

  Future<PruneResult> prune() async {
    final expired = await _store.deleteExpired(_clock());
    final overflow = _store.length - maxEntries;
    final evicted = overflow > 0
        ? await _store.deleteLeastRecentlyAccessed(overflow)
        : 0;
    return (expired: expired, evicted: evicted);
  }
}

/// The pruner for the whole app, on the one [CacheStore].
@Riverpod(keepAlive: true)
CachePruner cachePruner(Ref ref) => CachePruner(ref.watch(cacheStoreProvider));
