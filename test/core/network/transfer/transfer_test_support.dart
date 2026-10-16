import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/transfer/download_service.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../../helpers/helpers.dart';

typedef TransferHandler =
    Future<ResponseBody> Function(
      RequestOptions options,
      Stream<Uint8List>? body,
    );

/// Adapter driven by one handler. The handler decides when to read the request
/// body (that is what drives send progress) and how a response streams.
class TransferAdapter implements HttpClientAdapter {
  TransferAdapter(this.handler);

  final TransferHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options, requestStream);
  }

  @override
  void close({bool force = false}) {}
}

/// Reads a whole request body as text (latin1, so binary parts do not throw).
Future<String> readBody(Stream<Uint8List>? body) async {
  final bytes = <int>[];
  if (body != null) await body.forEach(bytes.addAll);
  return String.fromCharCodes(bytes);
}

/// A temp directory removed when the test ends.
Directory tempDir() {
  final dir = Directory.systemTemp.createTempSync('transfer_test_');
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dir;
}

ProviderContainer transferContainer({
  required HttpClientAdapter adapter,
  required Directory directory,
}) {
  return createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(
        const AppConfig(
          flavor: Flavor.dev,
          appName: 'Test',
          apiBaseUrl: 'https://api.example.test',
          connectTimeout: Duration(seconds: 15),
          receiveTimeout: Duration(seconds: 30),
          logLevel: LogLevel.error,
          enableCrashReporting: false,
          enableAnalytics: false,
        ),
      ),
      httpClientAdapterProvider.overrideWithValue(adapter),
      secureStorageProvider.overrideWithValue(FakeSecureStorage()),
      networkSleepProvider.overrideWithValue((_) async {}),
      transferDirectoryProvider.overrideWithValue(() async => directory),
    ],
  );
}
