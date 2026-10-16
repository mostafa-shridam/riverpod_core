import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Dio adapter with a queue of canned responses or errors. Every request is
/// recorded in [requests]. An empty queue fails the test loudly.
class FakeHttpAdapter implements HttpClientAdapter {
  final Queue<Future<ResponseBody> Function()> _queue = Queue();

  /// Requests received, in order.
  final List<RequestOptions> requests = [];

  /// Queues a JSON response with [statusCode] and [body].
  void enqueueJson(int statusCode, Object? body) {
    _queue.add(
      () async => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  /// Queues an error thrown by the adapter (for example a socket failure).
  void enqueueError(Object error) {
    _queue.add(() async => throw error);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    if (_queue.isEmpty) {
      return Future.error(
        StateError('FakeHttpAdapter: no response queued for ${options.uri}'),
      );
    }
    return _queue.removeFirst()();
  }

  @override
  void close({bool force = false}) {}
}
