import 'dart:convert';

import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/cache/cache_result.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

/// The one read of the remote config, cache first (D-038): the cached copy at
/// once (stale when older than [ttl]), then the server. With no cache and no
/// server the stream errors; callers fall back to [RemoteConfig.defaults].
class RemoteConfigRepository {
  RemoteConfigRepository(this._cache, this._source);

  static const cacheKey = 'remote_config';

  /// How long a fetched copy counts as fresh. An older copy is still served.
  static const ttl = Duration(hours: 1);

  final CachedRepositoryHelper _cache;
  final RemoteConfigSource _source;

  Stream<CacheResult<RemoteConfig>> watch() => _cache.watch<RemoteConfig>(
    key: cacheKey,
    fetch: _source.fetch,
    decode: (payload) =>
        RemoteConfig.fromJson(jsonDecode(payload) as Map<String, dynamic>),
    encode: (config) => jsonEncode(config.toJson()),
    ttl: ttl,
  );
}
