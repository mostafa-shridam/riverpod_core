import 'dart:async';

import 'package:riverpod_core/core/errors/app_exception.dart';

/// Receives progress as a fraction from 0 to 1.
typedef TransferProgressCallback = void Function(double progress);

/// Turns sent/received byte counts into a fraction in 0..1. An unknown total
/// (zero or negative) gives 0 so the UI can show an indeterminate bar.
double progressFraction(int count, int total) {
  if (total <= 0) return 0;
  return (count / total).clamp(0.0, 1.0);
}

/// Progress as a `Stream<double>`: pass [report] as `onProgress` and listen to
/// [stream]. Broadcast, so late listeners are fine; call [close] when done.
class ProgressStream {
  final _controller = StreamController<double>.broadcast();

  Stream<double> get stream => _controller.stream;

  void report(double progress) {
    if (!_controller.isClosed) _controller.add(progress);
  }

  Future<void> close() => _controller.close();
}

/// State of one transfer, as exposed by `TransferController`.
sealed class TransferState {
  const TransferState();
}

final class TransferIdle extends TransferState {
  const TransferIdle();
}

final class TransferRunning extends TransferState {
  const TransferRunning(this.progress);

  /// 0..1.
  final double progress;
}

final class TransferDone extends TransferState {
  const TransferDone(this.result);

  /// An `UploadResult` for uploads, the saved `File` for downloads.
  final Object result;
}

final class TransferFailed extends TransferState {
  const TransferFailed(this.error);

  final AppException error;
}

final class TransferCancelled extends TransferState {
  const TransferCancelled();
}
