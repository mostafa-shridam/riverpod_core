import 'package:dio/dio.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';

/// Fetches the remote config from the server. Throws `DioException` or an
/// `AppException`; the repository maps errors.
abstract interface class RemoteConfigSource {
  /// [etag] is the ETag of the stored copy; a 304 answer means it still stands.
  Future<CacheFetch<RemoteConfig>> fetch({String? etag});
}

/// Reads the config from [path] over Dio (D-040).
class HttpRemoteConfigSource implements RemoteConfigSource {
  HttpRemoteConfigSource(this._dio, this._path);

  final Dio _dio;
  final String _path;

  @override
  Future<CacheFetch<RemoteConfig>> fetch({String? etag}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      options: Options(
        headers: etag == null ? null : {'If-None-Match': etag},
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) || status == 304),
      ),
    );
    if (response.statusCode == 304) {
      return (value: null, etag: etag);
    }
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
  Future<CacheFetch<RemoteConfig>> fetch({String? etag}) async => (
    value: const RemoteConfig(minVersion: '0.0.0', latestVersion: '0.0.0'),
    etag: null,
  );
}
