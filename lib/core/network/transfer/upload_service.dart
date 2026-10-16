import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/transfer/transfer_progress.dart';

part 'upload_service.g.dart';

/// One file part of a multipart upload.
class UploadFile {
  const UploadFile({
    required this.field,
    required this.filePath,
    this.fileName,
    this.contentType,
  });

  /// Form field name the server expects.
  final String field;
  final String filePath;

  /// Name sent to the server; defaults to the file's own name.
  final String? fileName;

  /// MIME type, for example `image/jpeg`; omitted when null.
  final String? contentType;
}

/// What the server answered to an upload.
class UploadResult {
  const UploadResult({required this.statusCode, this.data});

  final int? statusCode;

  /// Decoded response body, if any.
  final Object? data;
}

/// Multipart upload through the app's `Dio` (NETWORKING.md "Upload / download").
class UploadService {
  UploadService(this._dio);

  final Dio _dio;

  /// POSTs [files] and [fields] as multipart to [path]. [onProgress] gets
  /// 0..1 while bytes are sent. Throws an `AppException`; a cancelled
  /// [cancelToken] throws `CancelledException`.
  Future<UploadResult> upload({
    required String path,
    List<UploadFile> files = const [],
    Map<String, String> fields = const {},
    TransferProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final form = FormData();
      fields.forEach((key, value) => form.fields.add(MapEntry(key, value)));
      for (final file in files) {
        form.files.add(
          MapEntry(
            file.field,
            await MultipartFile.fromFile(
              file.filePath,
              filename: file.fileName,
              contentType: file.contentType == null
                  ? null
                  : DioMediaType.parse(file.contentType!),
            ),
          ),
        );
      }
      final response = await _dio.post<Object?>(
        path,
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress == null
            ? null
            : (sent, total) => onProgress(progressFraction(sent, total)),
      );
      return UploadResult(statusCode: response.statusCode, data: response.data);
    } on Object catch (error, stack) {
      throw mapError(error, stack);
    }
  }
}

@Riverpod(keepAlive: true)
UploadService uploadService(Ref ref) => UploadService(ref.watch(dioProvider));
