// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Video _$VideoFromJson(Map<String, dynamic> json) => _Video(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  url: json['url'] as String,
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$VideoToJson(_Video instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'url': instance.url,
  'durationSeconds': instance.durationSeconds,
  'thumbnailUrl': instance.thumbnailUrl,
};
