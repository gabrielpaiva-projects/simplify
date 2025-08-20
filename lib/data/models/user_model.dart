import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
    String? phone,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isEmailVerified,
    @Default(true) bool isActive,
    @Default('user') String role,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      phone: user.phone,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isEmailVerified: user.isEmailVerified,
      isActive: user.isActive,
      role: user.role.name,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      role: UserRole.values.firstWhere(
        (r) => r.name == role,
        orElse: () => UserRole.user,
      ),
    );
  }
}