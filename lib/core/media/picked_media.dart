import 'package:flutter/foundation.dart';

/// A file chosen by the user (and processed, for images).
@immutable
class PickedMedia {
  const PickedMedia({
    required this.path,
    required this.size,
    required this.mimeType,
  });

  /// Absolute path of a readable file in the app sandbox or cache.
  final String path;

  /// Size in bytes.
  final int size;

  /// Best-effort MIME type from the file extension.
  final String mimeType;

  @override
  bool operator ==(Object other) =>
      other is PickedMedia &&
      other.path == path &&
      other.size == size &&
      other.mimeType == mimeType;

  @override
  int get hashCode => Object.hash(path, size, mimeType);

  @override
  String toString() => 'PickedMedia($path, $size bytes, $mimeType)';
}

const _mimeByExtension = <String, String>{
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'heif': 'image/heif',
  'bmp': 'image/bmp',
  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'm4v': 'video/x-m4v',
  'webm': 'video/webm',
  'mp3': 'audio/mpeg',
  'm4a': 'audio/mp4',
  'wav': 'audio/wav',
  'pdf': 'application/pdf',
  'txt': 'text/plain',
  'csv': 'text/csv',
  'json': 'application/json',
  'zip': 'application/zip',
  'doc': 'application/msword',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

/// MIME type for [path] from its extension; `application/octet-stream` when
/// unknown.
String mimeTypeOfPath(String path) {
  final name = path.split(RegExp(r'[\\/]')).last;
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return 'application/octet-stream';
  return _mimeByExtension[name.substring(dot + 1).toLowerCase()] ??
      'application/octet-stream';
}
