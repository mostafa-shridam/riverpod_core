import 'package:riverpod_core/core/errors/app_exception.dart';

/// A value from the cache or the network, with how fresh it is.
class CacheResult<T> {
  const CacheResult({
    required this.data,
    required this.isStale,
    required this.savedAt,
    this.error,
  });

  final T data;

  /// True when the value is older than its ttl, or a fetch failed and this is
  /// the cached copy. Pages show the stale state for this.
  final bool isStale;

  /// When the value was fetched, from the cache clock.
  final DateTime savedAt;

  /// The fetch failure behind a stale value. Null when no fetch failed.
  final AppException? error;
}
