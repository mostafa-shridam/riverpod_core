// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteMaintenance {

 bool get enabled; String? get message;
/// Create a copy of RemoteMaintenance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteMaintenanceCopyWith<RemoteMaintenance> get copyWith => _$RemoteMaintenanceCopyWithImpl<RemoteMaintenance>(this as RemoteMaintenance, _$identity);

  /// Serializes this RemoteMaintenance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RemoteMaintenance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteMaintenance&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RemoteMaintenance;
  return Object.hash(runtimeType,_this.enabled,_this.message);
}

@override
String toString() {
  final _this = this as RemoteMaintenance;
  return 'RemoteMaintenance(enabled: ${_this.enabled}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $RemoteMaintenanceCopyWith<$Res>  {
  factory $RemoteMaintenanceCopyWith(RemoteMaintenance value, $Res Function(RemoteMaintenance) _then) = _$RemoteMaintenanceCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? message
});




}
/// @nodoc
class _$RemoteMaintenanceCopyWithImpl<$Res>
    implements $RemoteMaintenanceCopyWith<$Res> {
  _$RemoteMaintenanceCopyWithImpl(this._self, this._then);

  final RemoteMaintenance _self;
  final $Res Function(RemoteMaintenance) _then;

/// Create a copy of RemoteMaintenance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? message = freezed,}) {
  return _then(RemoteMaintenance(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteMaintenance].
extension RemoteMaintenancePatterns on RemoteMaintenance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteMaintenance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteMaintenance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteMaintenance value)  $default,){
final _that = this;
switch (_that) {
case _RemoteMaintenance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteMaintenance value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteMaintenance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteMaintenance() when $default != null:
return $default(_that.enabled,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? message)  $default,) {final _that = this;
switch (_that) {
case _RemoteMaintenance():
return $default(_that.enabled,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _RemoteMaintenance() when $default != null:
return $default(_that.enabled,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteMaintenance implements RemoteMaintenance {
  const _RemoteMaintenance({this.enabled = false, this.message});
  factory _RemoteMaintenance.fromJson(Map<String, dynamic> json) => _$RemoteMaintenanceFromJson(json);

@override@JsonKey() final  bool enabled;
@override final  String? message;

/// Create a copy of RemoteMaintenance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteMaintenanceCopyWith<_RemoteMaintenance> get copyWith => __$RemoteMaintenanceCopyWithImpl<_RemoteMaintenance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteMaintenanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteMaintenance&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,message);
}

@override
String toString() {
    return 'RemoteMaintenance(enabled: $enabled, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RemoteMaintenanceCopyWith<$Res> implements $RemoteMaintenanceCopyWith<$Res> {
  factory _$RemoteMaintenanceCopyWith(_RemoteMaintenance value, $Res Function(_RemoteMaintenance) _then) = __$RemoteMaintenanceCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? message
});




}
/// @nodoc
class __$RemoteMaintenanceCopyWithImpl<$Res>
    implements _$RemoteMaintenanceCopyWith<$Res> {
  __$RemoteMaintenanceCopyWithImpl(this._self, this._then);

  final _RemoteMaintenance _self;
  final $Res Function(_RemoteMaintenance) _then;

/// Create a copy of RemoteMaintenance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? message = freezed,}) {
  return _then(_RemoteMaintenance(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RemoteConfig {

/// Oldest version allowed to run. Older builds get the force update page.
 String get minVersion;/// Newest published version. Older builds get a dismissible update notice.
 String get latestVersion;/// Where the store page is; the update pages open it.
 String? get storeUrl; RemoteMaintenance get maintenance;/// Feature flags by name. A missing flag reads as false.
 Map<String, bool> get flags;
/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteConfigCopyWith<RemoteConfig> get copyWith => _$RemoteConfigCopyWithImpl<RemoteConfig>(this as RemoteConfig, _$identity);

  /// Serializes this RemoteConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RemoteConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteConfig&&(identical(other.minVersion, _this.minVersion) || other.minVersion == _this.minVersion)&&(identical(other.latestVersion, _this.latestVersion) || other.latestVersion == _this.latestVersion)&&(identical(other.storeUrl, _this.storeUrl) || other.storeUrl == _this.storeUrl)&&(identical(other.maintenance, _this.maintenance) || other.maintenance == _this.maintenance)&&const DeepCollectionEquality().equals(other.flags, _this.flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RemoteConfig;
  return Object.hash(runtimeType,_this.minVersion,_this.latestVersion,_this.storeUrl,_this.maintenance,const DeepCollectionEquality().hash(_this.flags));
}

@override
String toString() {
  final _this = this as RemoteConfig;
  return 'RemoteConfig(minVersion: ${_this.minVersion}, latestVersion: ${_this.latestVersion}, storeUrl: ${_this.storeUrl}, maintenance: ${_this.maintenance}, flags: ${_this.flags})';
}


}

/// @nodoc
abstract mixin class $RemoteConfigCopyWith<$Res>  {
  factory $RemoteConfigCopyWith(RemoteConfig value, $Res Function(RemoteConfig) _then) = _$RemoteConfigCopyWithImpl;
@useResult
$Res call({
 String minVersion, String latestVersion, String? storeUrl, RemoteMaintenance maintenance, Map<String, bool> flags
});


$RemoteMaintenanceCopyWith<$Res> get maintenance;

}
/// @nodoc
class _$RemoteConfigCopyWithImpl<$Res>
    implements $RemoteConfigCopyWith<$Res> {
  _$RemoteConfigCopyWithImpl(this._self, this._then);

  final RemoteConfig _self;
  final $Res Function(RemoteConfig) _then;

/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minVersion = null,Object? latestVersion = null,Object? storeUrl = freezed,Object? maintenance = null,Object? flags = null,}) {
  return _then(RemoteConfig(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as RemoteMaintenance,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}
/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteMaintenanceCopyWith<$Res> get maintenance {
  
  return $RemoteMaintenanceCopyWith<$Res>(_self.maintenance, (value) {
    return _then(_self.copyWith(maintenance: value));
  });
}
}


/// Adds pattern-matching-related methods to [RemoteConfig].
extension RemoteConfigPatterns on RemoteConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteConfig value)  $default,){
final _that = this;
switch (_that) {
case _RemoteConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String minVersion,  String latestVersion,  String? storeUrl,  RemoteMaintenance maintenance,  Map<String, bool> flags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteConfig() when $default != null:
return $default(_that.minVersion,_that.latestVersion,_that.storeUrl,_that.maintenance,_that.flags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String minVersion,  String latestVersion,  String? storeUrl,  RemoteMaintenance maintenance,  Map<String, bool> flags)  $default,) {final _that = this;
switch (_that) {
case _RemoteConfig():
return $default(_that.minVersion,_that.latestVersion,_that.storeUrl,_that.maintenance,_that.flags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String minVersion,  String latestVersion,  String? storeUrl,  RemoteMaintenance maintenance,  Map<String, bool> flags)?  $default,) {final _that = this;
switch (_that) {
case _RemoteConfig() when $default != null:
return $default(_that.minVersion,_that.latestVersion,_that.storeUrl,_that.maintenance,_that.flags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteConfig implements RemoteConfig {
  const _RemoteConfig({required this.minVersion, required this.latestVersion, this.storeUrl, this.maintenance = const RemoteMaintenance(),  Map<String, bool> flags = const <String, bool>{}}): _flags = flags;
  factory _RemoteConfig.fromJson(Map<String, dynamic> json) => _$RemoteConfigFromJson(json);

/// Oldest version allowed to run. Older builds get the force update page.
@override final  String minVersion;
/// Newest published version. Older builds get a dismissible update notice.
@override final  String latestVersion;
/// Where the store page is; the update pages open it.
@override final  String? storeUrl;
@override@JsonKey() final  RemoteMaintenance maintenance;
/// Feature flags by name. A missing flag reads as false.
 final  Map<String, bool> _flags;
/// Feature flags by name. A missing flag reads as false.
@override@JsonKey() Map<String, bool> get flags {
  if (_flags is EqualUnmodifiableMapView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_flags);
}


/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteConfigCopyWith<_RemoteConfig> get copyWith => __$RemoteConfigCopyWithImpl<_RemoteConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteConfig&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&const DeepCollectionEquality().equals(other.flags, _flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minVersion,latestVersion,storeUrl,maintenance,const DeepCollectionEquality().hash(_flags));
}

@override
String toString() {
    return 'RemoteConfig(minVersion: $minVersion, latestVersion: $latestVersion, storeUrl: $storeUrl, maintenance: $maintenance, flags: $flags)';
}


}

/// @nodoc
abstract mixin class _$RemoteConfigCopyWith<$Res> implements $RemoteConfigCopyWith<$Res> {
  factory _$RemoteConfigCopyWith(_RemoteConfig value, $Res Function(_RemoteConfig) _then) = __$RemoteConfigCopyWithImpl;
@override @useResult
$Res call({
 String minVersion, String latestVersion, String? storeUrl, RemoteMaintenance maintenance, Map<String, bool> flags
});


@override $RemoteMaintenanceCopyWith<$Res> get maintenance;

}
/// @nodoc
class __$RemoteConfigCopyWithImpl<$Res>
    implements _$RemoteConfigCopyWith<$Res> {
  __$RemoteConfigCopyWithImpl(this._self, this._then);

  final _RemoteConfig _self;
  final $Res Function(_RemoteConfig) _then;

/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minVersion = null,Object? latestVersion = null,Object? storeUrl = freezed,Object? maintenance = null,Object? flags = null,}) {
  return _then(_RemoteConfig(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as RemoteMaintenance,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

/// Create a copy of RemoteConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteMaintenanceCopyWith<$Res> get maintenance {
  
  return $RemoteMaintenanceCopyWith<$Res>(_self.maintenance, (value) {
    return _then(_self.copyWith(maintenance: value));
  });
}
}

// dart format on
