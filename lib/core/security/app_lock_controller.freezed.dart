// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_lock_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLockState {

/// The user turned app lock on.
 bool get enabled;/// The content is hidden until the user authenticates.
 bool get locked;/// The app is not in the foreground: content is hidden in the app
/// switcher even before the timeout passed.
 bool get obscured;/// A system prompt is showing.
 bool get unlocking;/// Result of the last attempt, for the lock screen message.
 BiometricResult? get lastResult;
/// Create a copy of AppLockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLockStateCopyWith<AppLockState> get copyWith => _$AppLockStateCopyWithImpl<AppLockState>(this as AppLockState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppLockState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLockState&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.obscured, _this.obscured) || other.obscured == _this.obscured)&&(identical(other.unlocking, _this.unlocking) || other.unlocking == _this.unlocking)&&(identical(other.lastResult, _this.lastResult) || other.lastResult == _this.lastResult));
}


@override
int get hashCode {
  final _this = this as AppLockState;
  return Object.hash(runtimeType,_this.enabled,_this.locked,_this.obscured,_this.unlocking,_this.lastResult);
}

@override
String toString() {
  final _this = this as AppLockState;
  return 'AppLockState(enabled: ${_this.enabled}, locked: ${_this.locked}, obscured: ${_this.obscured}, unlocking: ${_this.unlocking}, lastResult: ${_this.lastResult})';
}


}

/// @nodoc
abstract mixin class $AppLockStateCopyWith<$Res>  {
  factory $AppLockStateCopyWith(AppLockState value, $Res Function(AppLockState) _then) = _$AppLockStateCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool locked, bool obscured, bool unlocking, BiometricResult? lastResult
});




}
/// @nodoc
class _$AppLockStateCopyWithImpl<$Res>
    implements $AppLockStateCopyWith<$Res> {
  _$AppLockStateCopyWithImpl(this._self, this._then);

  final AppLockState _self;
  final $Res Function(AppLockState) _then;

/// Create a copy of AppLockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? locked = null,Object? obscured = null,Object? unlocking = null,Object? lastResult = freezed,}) {
  return _then(AppLockState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,obscured: null == obscured ? _self.obscured : obscured // ignore: cast_nullable_to_non_nullable
as bool,unlocking: null == unlocking ? _self.unlocking : unlocking // ignore: cast_nullable_to_non_nullable
as bool,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as BiometricResult?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLockState].
extension AppLockStatePatterns on AppLockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLockState value)  $default,){
final _that = this;
switch (_that) {
case _AppLockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLockState value)?  $default,){
final _that = this;
switch (_that) {
case _AppLockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool locked,  bool obscured,  bool unlocking,  BiometricResult? lastResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLockState() when $default != null:
return $default(_that.enabled,_that.locked,_that.obscured,_that.unlocking,_that.lastResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool locked,  bool obscured,  bool unlocking,  BiometricResult? lastResult)  $default,) {final _that = this;
switch (_that) {
case _AppLockState():
return $default(_that.enabled,_that.locked,_that.obscured,_that.unlocking,_that.lastResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool locked,  bool obscured,  bool unlocking,  BiometricResult? lastResult)?  $default,) {final _that = this;
switch (_that) {
case _AppLockState() when $default != null:
return $default(_that.enabled,_that.locked,_that.obscured,_that.unlocking,_that.lastResult);case _:
  return null;

}
}

}

/// @nodoc


class _AppLockState implements AppLockState {
  const _AppLockState({this.enabled = false, this.locked = false, this.obscured = false, this.unlocking = false, this.lastResult});
  

/// The user turned app lock on.
@override@JsonKey() final  bool enabled;
/// The content is hidden until the user authenticates.
@override@JsonKey() final  bool locked;
/// The app is not in the foreground: content is hidden in the app
/// switcher even before the timeout passed.
@override@JsonKey() final  bool obscured;
/// A system prompt is showing.
@override@JsonKey() final  bool unlocking;
/// Result of the last attempt, for the lock screen message.
@override final  BiometricResult? lastResult;

/// Create a copy of AppLockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLockStateCopyWith<_AppLockState> get copyWith => __$AppLockStateCopyWithImpl<_AppLockState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLockState&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.obscured, obscured) || other.obscured == obscured)&&(identical(other.unlocking, unlocking) || other.unlocking == unlocking)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,locked,obscured,unlocking,lastResult);
}

@override
String toString() {
    return 'AppLockState(enabled: $enabled, locked: $locked, obscured: $obscured, unlocking: $unlocking, lastResult: $lastResult)';
}


}

/// @nodoc
abstract mixin class _$AppLockStateCopyWith<$Res> implements $AppLockStateCopyWith<$Res> {
  factory _$AppLockStateCopyWith(_AppLockState value, $Res Function(_AppLockState) _then) = __$AppLockStateCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool locked, bool obscured, bool unlocking, BiometricResult? lastResult
});




}
/// @nodoc
class __$AppLockStateCopyWithImpl<$Res>
    implements _$AppLockStateCopyWith<$Res> {
  __$AppLockStateCopyWithImpl(this._self, this._then);

  final _AppLockState _self;
  final $Res Function(_AppLockState) _then;

/// Create a copy of AppLockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? locked = null,Object? obscured = null,Object? unlocking = null,Object? lastResult = freezed,}) {
  return _then(_AppLockState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,obscured: null == obscured ? _self.obscured : obscured // ignore: cast_nullable_to_non_nullable
as bool,unlocking: null == unlocking ? _self.unlocking : unlocking // ignore: cast_nullable_to_non_nullable
as bool,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as BiometricResult?,
  ));
}


}

// dart format on
