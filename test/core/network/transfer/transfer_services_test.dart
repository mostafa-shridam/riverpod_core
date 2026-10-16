import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/transfer/download_service.dart';
import 'package:riverpod_core/core/network/transfer/transfer_progress.dart';
import 'package:riverpod_core/core/network/transfer/upload_service.dart';

import 'transfer_test_support.dart';

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  group('UploadService', () {
    test('sends fields and files as multipart and reports progress', () async {
      final dir = tempDir();
      final file = File('${dir.path}/photo.jpg')
        ..writeAsBytesSync(List<int>.filled(4096, 65));
      String? body;
      final adapter = TransferAdapter((options, stream) async {
        body = await readBody(stream);
        return _json(201, {'id': 7});
      });
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(uploadServiceProvider);
      final progress = <double>[];

      final result = await service.upload(
        path: '/files',
        fields: {'title': 'My photo'},
        files: [
          UploadFile(
            field: 'file',
            filePath: file.path,
            fileName: 'upload.jpg',
            contentType: 'image/jpeg',
          ),
        ],
        onProgress: progress.add,
      );

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/files');
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(body, contains('name="title"'));
      expect(body, contains('My photo'));
      expect(body, contains('name="file"; filename="upload.jpg"'));
      expect(body, contains('image/jpeg'));
      expect(result.statusCode, 201);
      expect(result.data, {'id': 7});
      expect(progress, isNotEmpty);
      expect(progress.last, 1.0);
      expect(progress, everyElement(inInclusiveRange(0.0, 1.0)));
    });

    test('a server error maps to AppException', () async {
      final dir = tempDir();
      final adapter = TransferAdapter((options, stream) async {
        await readBody(stream);
        return _json(500, {'message': 'boom'});
      });
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(uploadServiceProvider);

      await expectLater(
        service.upload(path: '/files', fields: {'a': 'b'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('a cancelled token throws CancelledException', () async {
      final dir = tempDir();
      final gate = Completer<void>();
      final adapter = TransferAdapter((options, stream) async {
        await gate.future;
        return _json(200, {});
      });
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(uploadServiceProvider);
      final token = CancelToken();

      final future = service.upload(
        path: '/files',
        fields: {'a': 'b'},
        cancelToken: token,
      );
      await Future<void>.delayed(Duration.zero);
      token.cancel();

      await expectLater(future, throwsA(isA<CancelledException>()));
      gate.complete();
    });
  });

  group('DownloadService', () {
    test('streams progress and renames the .part file on success', () async {
      final dir = tempDir();
      final adapter = TransferAdapter((options, stream) async {
        return ResponseBody(
          Stream.fromIterable([
            Uint8List.fromList(List.filled(5, 1)),
            Uint8List.fromList(List.filled(5, 2)),
          ]),
          200,
          headers: {
            Headers.contentLengthHeader: ['10'],
          },
        );
      });
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(downloadServiceProvider);
      final stream = ProgressStream();
      final seen = <double>[];
      stream.stream.listen(seen.add);

      final file = await service.download(
        'https://files.example.test/a.bin',
        'a.bin',
        onProgress: stream.report,
      );
      await Future<void>.delayed(Duration.zero);

      expect(file.path, '${dir.path}/a.bin');
      expect(file.lengthSync(), 10);
      expect(File('${dir.path}/a.bin.part').existsSync(), isFalse);
      expect(seen.last, 1.0);
      expect(seen, contains(0.5));
      await stream.close();
    });

    test('cancel mid-transfer removes the partial file', () async {
      final dir = tempDir();
      final chunks = StreamController<Uint8List>();
      final adapter = TransferAdapter((options, stream) async {
        return ResponseBody(
          chunks.stream,
          200,
          headers: {
            Headers.contentLengthHeader: ['10'],
          },
        );
      });
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(downloadServiceProvider);
      final token = CancelToken();
      final half = Completer<void>();

      final future = service.download(
        'https://files.example.test/a.bin',
        'a.bin',
        cancelToken: token,
        onProgress: (p) {
          if (p >= 0.5 && !half.isCompleted) half.complete();
        },
      );
      final expectation = expectLater(
        future,
        throwsA(isA<CancelledException>()),
      );
      await Future<void>.delayed(Duration.zero);
      chunks.add(Uint8List.fromList(List.filled(5, 1)));
      await half.future;
      token.cancel();
      await expectation;
      await chunks.close();

      expect(dir.listSync(), isEmpty);
    });

    test('a failure maps to AppException and keeps no file', () async {
      final dir = tempDir();
      final adapter = TransferAdapter(
        (options, stream) async => _json(404, {'message': 'gone'}),
      );
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(downloadServiceProvider);

      await expectLater(
        service.download('https://files.example.test/a.bin', 'a.bin'),
        throwsA(isA<NotFoundException>()),
      );
      expect(dir.listSync(), isEmpty);
    });

    test('a connection failure maps to NetworkException', () async {
      final dir = tempDir();
      final adapter = TransferAdapter(
        (options, stream) async => throw const SocketException('down'),
      );
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(downloadServiceProvider);

      await expectLater(
        service.download('https://files.example.test/a.bin', 'a.bin'),
        throwsA(isA<NetworkException>()),
      );
      expect(dir.listSync(), isEmpty);
    });

    test('a file name cannot escape the directory', () async {
      final dir = tempDir();
      final adapter = TransferAdapter(
        (options, stream) async => ResponseBody.fromBytes([1, 2, 3], 200),
      );
      final service = transferContainer(
        adapter: adapter,
        directory: dir,
      ).read(downloadServiceProvider);

      final file = await service.download('https://x.test/a', '../../evil.bin');

      expect(file.path, '${dir.path}/evil.bin');
    });
  });

  group('progressFraction', () {
    test('clamps and handles an unknown total', () {
      expect(progressFraction(5, 10), 0.5);
      expect(progressFraction(20, 10), 1.0);
      expect(progressFraction(5, -1), 0.0);
    });
  });
}
