import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/transfer/transfer_progress.dart';

part 'download_service.g.dart';

/// Where downloads are saved. Default: the app cache directory. Tests
/// override it with a temp directory.
@Riverpod(keepAlive: true)
Future<Directory> Function() transferDirectory(Ref ref) =>
    getApplicationCacheDirectory;

/// Downloads a file to a `.part` file and renames it on success. The partial
/// file is deleted on cancel and on failure; resuming is not supported.
class DownloadService {
  DownloadService(this._dio, this._directory);

  final Dio _dio;
  final Future<Directory> Function() _directory;

  /// Saves [url] as [fileName] in the transfer directory and returns the file.
  /// [onProgress] gets 0..1 (stays 0 when the server sends no length).
  /// Throws an `AppException`; a cancel throws `CancelledException`.
  Future<File> download(
    String url,
    String fileName, {
    TransferProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Keep only the last path segment so a name cannot escape the directory.
    final safeName = fileName.split(RegExp(r'[/\\]')).last;
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw const UnknownException(message: 'Invalid download file name');
    }
    File? part;
    try {
      final dir = await _directory();
      await dir.create(recursive: true);
      final target = '${dir.path}${Platform.pathSeparator}$safeName';
      part = File('$target.part');
      await _dio.download(
        url,
        part.path,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress == null
            ? null
            : (received, total) =>
                  onProgress(progressFraction(received, total)),
      );
      return await part.rename(target);
    } on Object catch (error, stack) {
      await _deleteQuietly(part);
      throw mapError(error, stack);
    }
  }

  Future<void> _deleteQuietly(File? file) async {
    try {
      if (file != null && file.existsSync()) await file.delete();
    } on FileSystemException {
      // Nothing more can be done; the original error is the one to report.
    }
  }
}

@Riverpod(keepAlive: true)
DownloadService downloadService(Ref ref) => DownloadService(
  ref.watch(dioProvider),
  ref.watch(transferDirectoryProvider),
);
