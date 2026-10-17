import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/transfer/transfer_controller.dart';
import 'package:riverpod_core/core/network/transfer/transfer_progress.dart';

import 'transfer_test_support.dart';

List<TransferState> _record(ProviderContainer container) {
  final states = <TransferState>[];
  container.listen(
    transferControllerProvider,
    (_, next) => states.add(next),
    fireImmediately: true,
  );
  return states;
}

void main() {
  test('download: idle, running with progress, done with the file', () async {
    final dir = tempDir();
    final adapter = TransferAdapter(
      (options, stream) async => ResponseBody(
        Stream.fromIterable([
          Uint8List.fromList(List.filled(5, 1)),
          Uint8List.fromList(List.filled(5, 2)),
        ]),
        200,
        headers: {
          Headers.contentLengthHeader: ['10'],
        },
      ),
    );
    final container = transferContainer(adapter: adapter, directory: dir);
    final states = _record(container);
    final controller = container.read(transferControllerProvider.notifier);

    await controller.download('https://files.example.test/a.bin', 'a.bin');

    expect(states.first, isA<TransferIdle>());
    final progress = states.whereType<TransferRunning>().map((s) => s.progress);
    expect(progress, containsAllInOrder([0.0, 0.5, 1.0]));
    final done = states.last as TransferDone;
    expect((done.result as File).path, '${dir.path}/a.bin');
  });

  test('upload: done carries the server result', () async {
    final dir = tempDir();
    final adapter = TransferAdapter((options, stream) async {
      await readBody(stream);
      return ResponseBody.fromString(
        jsonEncode({'ok': true}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final container = transferContainer(adapter: adapter, directory: dir);
    _record(container); // keeps the autoDispose provider alive

    final controller = container.read(transferControllerProvider.notifier);

    await controller.upload(path: '/files', fields: {'a': 'b'});

    final state = container.read(transferControllerProvider) as TransferDone;
    expect(state.result, isNotNull);
  });

  test('failure becomes TransferFailed with an AppException', () async {
    final dir = tempDir();
    final adapter = TransferAdapter(
      (options, stream) async => ResponseBody.fromString('{}', 403),
    );
    final container = transferContainer(adapter: adapter, directory: dir);
    _record(container); // keeps the autoDispose provider alive

    final controller = container.read(transferControllerProvider.notifier);

    await controller.download('https://files.example.test/a.bin', 'a.bin');

    final state = container.read(transferControllerProvider);
    expect(state, isA<TransferFailed>());
    expect((state as TransferFailed).error, isA<ForbiddenException>());
    expect(dir.listSync(), isEmpty);
  });

  test('cancel() mid-transfer gives cancelled and removes the file', () async {
    final dir = tempDir();
    final chunks = StreamController<Uint8List>();
    final adapter = TransferAdapter(
      (options, stream) async => ResponseBody(
        chunks.stream,
        200,
        headers: {
          Headers.contentLengthHeader: ['10'],
        },
      ),
    );
    final container = transferContainer(adapter: adapter, directory: dir);
    _record(container); // keeps the autoDispose provider alive

    final controller = container.read(transferControllerProvider.notifier);

    // Gate: completes when the controller reports the first chunk (0.5), so
    // the part file exists before cancel(); no sleeping, no timing guess.
    final firstChunk = Completer<void>();
    container.listen(transferControllerProvider, (_, next) {
      if (next is TransferRunning &&
          next.progress == 0.5 &&
          !firstChunk.isCompleted) {
        firstChunk.complete();
      }
    });

    final future = controller.download('https://x.test/a.bin', 'a.bin');
    chunks.add(Uint8List.fromList(List.filled(5, 1)));
    await firstChunk.future;
    expect(container.read(transferControllerProvider), isA<TransferRunning>());

    controller.cancel();
    expect(
      container.read(transferControllerProvider),
      isA<TransferCancelled>(),
    );
    await future;
    await chunks.close();

    expect(
      container.read(transferControllerProvider),
      isA<TransferCancelled>(),
    );
    expect(dir.listSync(), isEmpty);
  });

  test('cancel() while idle does nothing; reset() returns to idle', () async {
    final dir = tempDir();
    final adapter = TransferAdapter(
      (options, stream) async => ResponseBody.fromString('{}', 500),
    );
    final container = transferContainer(adapter: adapter, directory: dir);
    _record(container); // keeps the autoDispose provider alive

    final controller = container.read(transferControllerProvider.notifier)
      ..cancel();
    expect(container.read(transferControllerProvider), isA<TransferIdle>());

    await controller.download('https://x.test/a.bin', 'a.bin');
    expect(container.read(transferControllerProvider), isA<TransferFailed>());
    controller.reset();
    expect(container.read(transferControllerProvider), isA<TransferIdle>());
  });
}
