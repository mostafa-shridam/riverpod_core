// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoFeed _$VideoFeedFromJson(Map<String, dynamic> json) => _VideoFeed(
  videos: (json['items'] as List<dynamic>)
      .map((e) => Video.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasPartialError: json['partial'] as bool? ?? false,
);

Map<String, dynamic> _$VideoFeedToJson(_VideoFeed instance) =>
    <String, dynamic>{
      'items': instance.videos,
      'partial': instance.hasPartialError,
    };
