// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideosState {

 List<Video> get videos; DateTime get loadedAt; String get query; bool get hasPartialError;
/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideosStateCopyWith<VideosState> get copyWith => _$VideosStateCopyWithImpl<VideosState>(this as VideosState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VideosState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosState&&const DeepCollectionEquality().equals(other.videos, _this.videos)&&(identical(other.loadedAt, _this.loadedAt) || other.loadedAt == _this.loadedAt)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.hasPartialError, _this.hasPartialError) || other.hasPartialError == _this.hasPartialError));
}


@override
int get hashCode {
  final _this = this as VideosState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.videos),_this.loadedAt,_this.query,_this.hasPartialError);
}

@override
String toString() {
  final _this = this as VideosState;
  return 'VideosState(videos: ${_this.videos}, loadedAt: ${_this.loadedAt}, query: ${_this.query}, hasPartialError: ${_this.hasPartialError})';
}


}

/// @nodoc
abstract mixin class $VideosStateCopyWith<$Res>  {
  factory $VideosStateCopyWith(VideosState value, $Res Function(VideosState) _then) = _$VideosStateCopyWithImpl;
@useResult
$Res call({
 List<Video> videos, DateTime loadedAt, String query, bool hasPartialError
});




}
/// @nodoc
class _$VideosStateCopyWithImpl<$Res>
    implements $VideosStateCopyWith<$Res> {
  _$VideosStateCopyWithImpl(this._self, this._then);

  final VideosState _self;
  final $Res Function(VideosState) _then;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? loadedAt = null,Object? query = null,Object? hasPartialError = null,}) {
  return _then(VideosState(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,loadedAt: null == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,hasPartialError: null == hasPartialError ? _self.hasPartialError : hasPartialError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideosState].
extension VideosStatePatterns on VideosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideosState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideosState value)  $default,){
final _that = this;
switch (_that) {
case _VideosState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideosState value)?  $default,){
final _that = this;
switch (_that) {
case _VideosState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Video> videos,  DateTime loadedAt,  String query,  bool hasPartialError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideosState() when $default != null:
return $default(_that.videos,_that.loadedAt,_that.query,_that.hasPartialError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Video> videos,  DateTime loadedAt,  String query,  bool hasPartialError)  $default,) {final _that = this;
switch (_that) {
case _VideosState():
return $default(_that.videos,_that.loadedAt,_that.query,_that.hasPartialError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Video> videos,  DateTime loadedAt,  String query,  bool hasPartialError)?  $default,) {final _that = this;
switch (_that) {
case _VideosState() when $default != null:
return $default(_that.videos,_that.loadedAt,_that.query,_that.hasPartialError);case _:
  return null;

}
}

}

/// @nodoc


class _VideosState extends VideosState {
  const _VideosState({required  List<Video> videos, required this.loadedAt, this.query = '', this.hasPartialError = false}): _videos = videos,super._();
  

 final  List<Video> _videos;
@override List<Video> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  DateTime loadedAt;
@override@JsonKey() final  String query;
@override@JsonKey() final  bool hasPartialError;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideosStateCopyWith<_VideosState> get copyWith => __$VideosStateCopyWithImpl<_VideosState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideosState&&const DeepCollectionEquality().equals(other.videos, _videos)&&(identical(other.loadedAt, loadedAt) || other.loadedAt == loadedAt)&&(identical(other.query, query) || other.query == query)&&(identical(other.hasPartialError, hasPartialError) || other.hasPartialError == hasPartialError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),loadedAt,query,hasPartialError);
}

@override
String toString() {
    return 'VideosState(videos: $videos, loadedAt: $loadedAt, query: $query, hasPartialError: $hasPartialError)';
}


}

/// @nodoc
abstract mixin class _$VideosStateCopyWith<$Res> implements $VideosStateCopyWith<$Res> {
  factory _$VideosStateCopyWith(_VideosState value, $Res Function(_VideosState) _then) = __$VideosStateCopyWithImpl;
@override @useResult
$Res call({
 List<Video> videos, DateTime loadedAt, String query, bool hasPartialError
});




}
/// @nodoc
class __$VideosStateCopyWithImpl<$Res>
    implements _$VideosStateCopyWith<$Res> {
  __$VideosStateCopyWithImpl(this._self, this._then);

  final _VideosState _self;
  final $Res Function(_VideosState) _then;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? loadedAt = null,Object? query = null,Object? hasPartialError = null,}) {
  return _then(_VideosState(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,loadedAt: null == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,hasPartialError: null == hasPartialError ? _self.hasPartialError : hasPartialError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
