import 'package:dio/dio.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

/// Fetches the remote config from the server. Throws `DioException` or an
/// `AppException`; the repository maps errors.
abstract interface class RemoteConfigSource {
  Future<CacheFetch<RemoteConfig>> fetch();
}

/// Reads the config from [path] over Dio (D-040).
class HttpRemoteConfigSource implements RemoteConfigSource {
  HttpRemoteConfigSource(this._dio, this._path);

  final Dio _dio;
  final String _path;

  @override
  Future<CacheFetch<RemoteConfig>> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(_path);
    return (
      value: RemoteConfig.fromJson(response.data ?? const {}),
      etag: response.headers.value('etag'),
    );
  }
}

/// A built-in config for `REMOTE_CONFIG_MOCK`: the app runs without a backend.
class MockRemoteConfigSource implements RemoteConfigSource {
  const MockRemoteConfigSource();

  @override
  Future<CacheFetch<RemoteConfig>> fetch() async => (
    value: const RemoteConfig(minVersion: '0.0.0', latestVersion: '0.0.0'),
    etag: null,
  );
}
