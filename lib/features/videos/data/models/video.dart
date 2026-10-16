import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

/// One playable video. [url] is a direct MP4 or an HLS (`.m3u8`) link: the
/// player cannot open page links such as YouTube (D-029).
@freezed
abstract class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String description,
    required String url,
    required int durationSeconds,
    String? thumbnailUrl,
  }) = _Video;

  const Video._();

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  /// Total length of the video.
  Duration get duration => Duration(seconds: durationSeconds);
}
