import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// Result of a successful sign-in: the tokens and the user they belong to.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AuthTokens tokens,
    required AuthUser user,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
