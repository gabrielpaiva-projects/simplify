import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_token.dart';

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

@freezed
class AuthTokenModel with _$AuthTokenModel {
  const AuthTokenModel._();

  const factory AuthTokenModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      tokenType: token.tokenType,
    );
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }
}