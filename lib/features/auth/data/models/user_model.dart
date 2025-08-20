import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    DateTime? emailVerifiedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;
  
  const UserModel._();
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  User toEntity() => User(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
    emailVerifiedAt: emailVerifiedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
    emailVerifiedAt: user.emailVerifiedAt,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  );
}