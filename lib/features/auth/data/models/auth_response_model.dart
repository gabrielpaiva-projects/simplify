import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

// part 'auth_response_model.freezed.dart'; // Will be generated
// part 'auth_response_model.g.dart'; // Will be generated

// Temporary implementation until code generation
@JsonSerializable()
class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final UserModel user;
  
  const AuthResponseModel({
    required this.token,
    this.refreshToken,
    required this.user,
  });
  
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
    token: json['token'] as String,
    refreshToken: json['refresh_token'] as String?,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
  
  Map<String, dynamic> toJson() => {
    'token': token,
    'refresh_token': refreshToken,
    'user': user.toJson(),
  };
}