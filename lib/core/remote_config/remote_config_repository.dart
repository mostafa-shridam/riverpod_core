import 'dart:convert';

import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_result.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

/// The one read of the remote config, cache first (D-038): the cached copy at
/// once (stale when older than the preset's ttl), then the server. With no
/// cache and no server the stream errors; callers fall back to
/// [RemoteConfig.defaults].
class RemoteConfigRepository {
  RemoteConfigRepository(this._cache, this._source);

  static const cacheKey = 'remote_config';

  /// Minutes, not hours: a force update must reach users soon after it ships.
  static const policy = CachePolicy.short;

  final CachedRepositoryHelper _cache;
  final RemoteConfigSource _source;

  Stream<CacheResult<RemoteConfig>> watch() => _cache.watch<RemoteConfig>(
    key: cacheKey,
    fetch: (etag) => _source.fetch(etag: etag),
    decode: (payload) =>
        RemoteConfig.fromJson(jsonDecode(payload) as Map<String, dynamic>),
    encode: (config) => jsonEncode(config.toJson()),
    policy: policy,
  );
}
