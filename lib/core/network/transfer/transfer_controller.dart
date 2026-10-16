import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/network/transfer/download_service.dart';
import 'package:riverpod_core/core/network/transfer/transfer_progress.dart';
import 'package:riverpod_core/core/network/transfer/upload_service.dart';

part 'transfer_controller.g.dart';

/// State and actions of one transfer. AutoDispose: leaving the screen cancels
/// a running transfer.
@riverpod
class TransferController extends _$TransferController {
  CancelToken? _token;
  var _run = 0;

  @override
  TransferState build() {
    ref.onDispose(() => _token?.cancel('disposed'));
    return const TransferIdle();
  }

  /// Uploads files; see `UploadService.upload`. Ignored while running.
  Future<void> upload({
    required String path,
    List<UploadFile> files = const [],
    Map<String, String> fields = const {},
  }) {
    final service = ref.read(uploadServiceProvider);
    return _start(
      (onProgress, token) => service.upload(
        path: path,
        files: files,
        fields: fields,
        onProgress: onProgress,
        cancelToken: token,
      ),
    );
  }

  /// Downloads a file; see `DownloadService.download`. Ignored while running.
  Future<void> download(String url, String fileName) {
    final service = ref.read(downloadServiceProvider);
    return _start(
      (onProgress, token) => service.download(
        url,
        fileName,
        onProgress: onProgress,
        cancelToken: token,
      ),
    );
  }

  /// Cancels the running transfer; no effect when nothing is running.
  void cancel() {
    if (state is! TransferRunning) return;
    _run++; // Whatever the cancelled call returns later is dropped.
    _token?.cancel('cancelled by user');
    state = const TransferCancelled();
  }

  /// Back to idle after done, failed or cancelled.
  void reset() {
    if (state is TransferRunning) return;
    state = const TransferIdle();
  }

  Future<void> _start(
    Future<Object> Function(
      TransferProgressCallback onProgress,
      CancelToken token,
    )
    run,
  ) async {
    if (state is TransferRunning) return;
    final id = ++_run;
    final token = _token = CancelToken();
    state = const TransferRunning(0);
    try {
      final result = await run((progress) {
        if (id == _run && ref.mounted) state = TransferRunning(progress);
      }, token);
      if (id == _run && ref.mounted) state = TransferDone(result);
    } on Object catch (error, stack) {
      if (id != _run || !ref.mounted) return;
      final mapped = mapError(error, stack);
      state = mapped is CancelledException
          ? const TransferCancelled()
          : TransferFailed(mapped);
    }
  }
}
