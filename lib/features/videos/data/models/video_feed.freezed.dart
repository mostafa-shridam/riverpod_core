// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoFeed {

@JsonKey(name: 'items') List<Video> get videos;@JsonKey(name: 'partial') bool get hasPartialError;
/// Create a copy of VideoFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoFeedCopyWith<VideoFeed> get copyWith => _$VideoFeedCopyWithImpl<VideoFeed>(this as VideoFeed, _$identity);

  /// Serializes this VideoFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoFeed;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoFeed&&const DeepCollectionEquality().equals(other.videos, _this.videos)&&(identical(other.hasPartialError, _this.hasPartialError) || other.hasPartialError == _this.hasPartialError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoFeed;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.videos),_this.hasPartialError);
}

@override
String toString() {
  final _this = this as VideoFeed;
  return 'VideoFeed(videos: ${_this.videos}, hasPartialError: ${_this.hasPartialError})';
}


}

/// @nodoc
abstract mixin class $VideoFeedCopyWith<$Res>  {
  factory $VideoFeedCopyWith(VideoFeed value, $Res Function(VideoFeed) _then) = _$VideoFeedCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'items') List<Video> videos,@JsonKey(name: 'partial') bool hasPartialError
});




}
/// @nodoc
class _$VideoFeedCopyWithImpl<$Res>
    implements $VideoFeedCopyWith<$Res> {
  _$VideoFeedCopyWithImpl(this._self, this._then);

  final VideoFeed _self;
  final $Res Function(VideoFeed) _then;

/// Create a copy of VideoFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? hasPartialError = null,}) {
  return _then(VideoFeed(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,hasPartialError: null == hasPartialError ? _self.hasPartialError : hasPartialError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoFeed].
extension VideoFeedPatterns on VideoFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoFeed value)  $default,){
final _that = this;
switch (_that) {
case _VideoFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoFeed value)?  $default,){
final _that = this;
switch (_that) {
case _VideoFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'items')  List<Video> videos, @JsonKey(name: 'partial')  bool hasPartialError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoFeed() when $default != null:
return $default(_that.videos,_that.hasPartialError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'items')  List<Video> videos, @JsonKey(name: 'partial')  bool hasPartialError)  $default,) {final _that = this;
switch (_that) {
case _VideoFeed():
return $default(_that.videos,_that.hasPartialError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'items')  List<Video> videos, @JsonKey(name: 'partial')  bool hasPartialError)?  $default,) {final _that = this;
switch (_that) {
case _VideoFeed() when $default != null:
return $default(_that.videos,_that.hasPartialError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoFeed implements VideoFeed {
  const _VideoFeed({@JsonKey(name: 'items') required  List<Video> videos, @JsonKey(name: 'partial') this.hasPartialError = false}): _videos = videos;
  factory _VideoFeed.fromJson(Map<String, dynamic> json) => _$VideoFeedFromJson(json);

 final  List<Video> _videos;
@override@JsonKey(name: 'items') List<Video> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override@JsonKey(name: 'partial') final  bool hasPartialError;

/// Create a copy of VideoFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoFeedCopyWith<_VideoFeed> get copyWith => __$VideoFeedCopyWithImpl<_VideoFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoFeedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoFeed&&const DeepCollectionEquality().equals(other.videos, _videos)&&(identical(other.hasPartialError, hasPartialError) || other.hasPartialError == hasPartialError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),hasPartialError);
}

@override
String toString() {
    return 'VideoFeed(videos: $videos, hasPartialError: $hasPartialError)';
}


}

/// @nodoc
abstract mixin class _$VideoFeedCopyWith<$Res> implements $VideoFeedCopyWith<$Res> {
  factory _$VideoFeedCopyWith(_VideoFeed value, $Res Function(_VideoFeed) _then) = __$VideoFeedCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'items') List<Video> videos,@JsonKey(name: 'partial') bool hasPartialError
});




}
/// @nodoc
class __$VideoFeedCopyWithImpl<$Res>
    implements _$VideoFeedCopyWith<$Res> {
  __$VideoFeedCopyWithImpl(this._self, this._then);

  final _VideoFeed _self;
  final $Res Function(_VideoFeed) _then;

/// Create a copy of VideoFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? hasPartialError = null,}) {
  return _then(_VideoFeed(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,hasPartialError: null == hasPartialError ? _self.hasPartialError : hasPartialError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
