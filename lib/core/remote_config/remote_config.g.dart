// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteMaintenance _$RemoteMaintenanceFromJson(Map<String, dynamic> json) =>
    _RemoteMaintenance(
      enabled: json['enabled'] as bool? ?? false,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RemoteMaintenanceToJson(_RemoteMaintenance instance) =>
    <String, dynamic>{'enabled': instance.enabled, 'message': instance.message};

_RemoteConfig _$RemoteConfigFromJson(Map<String, dynamic> json) =>
    _RemoteConfig(
      minVersion: json['minVersion'] as String,
      latestVersion: json['latestVersion'] as String,
      storeUrl: json['storeUrl'] as String?,
      maintenance: json['maintenance'] == null
          ? const RemoteMaintenance()
          : RemoteMaintenance.fromJson(
              json['maintenance'] as Map<String, dynamic>,
            ),
      flags:
          (json['flags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const <String, bool>{},
    );

Map<String, dynamic> _$RemoteConfigToJson(_RemoteConfig instance) =>
    <String, dynamic>{
      'minVersion': instance.minVersion,
      'latestVersion': instance.latestVersion,
      'storeUrl': instance.storeUrl,
      'maintenance': instance.maintenance,
      'flags': instance.flags,
    };
