import 'package:dio/dio.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registration.dart';

/// The one place that names the token endpoint. Change it to your API.
const pushTokenEndpoint = '/devices/push-token';

/// Example [PushTokenRegistrar] over the app's Dio client:
/// `POST pushTokenEndpoint` registers, `DELETE pushTokenEndpoint` removes.
///
/// DISABLED BY DEFAULT: `pushTokenRegistrarProvider` returns the no-op
/// registrar. To use this one, override that provider:
/// `pushTokenRegistrarProvider.overrideWith((ref) => DioPushTokenRegistrar(ref.watch(dioProvider)))`.
/// Errors surface as the `AppException`s the Dio error interceptor maps.
class DioPushTokenRegistrar implements PushTokenRegistrar {
  const DioPushTokenRegistrar(this._dio);

  final Dio _dio;

  @override
  Future<void> register(PushTokenRegistration registration) async {
    await _dio.post<void>(
      pushTokenEndpoint,
      data: {
        'token': registration.token,
        'previousToken': ?registration.previousToken,
        'platform': registration.device.platform,
        'deviceId': registration.device.installationId,
        'model': registration.device.model,
        'osVersion': registration.device.osVersion,
      },
    );
  }

  @override
  Future<void> unregister(String token) async {
    await _dio.delete<void>(pushTokenEndpoint, data: {'token': token});
  }
}
