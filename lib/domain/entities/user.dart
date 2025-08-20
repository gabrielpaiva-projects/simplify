import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.isActive = true,
    this.role = UserRole.user,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        phone,
        createdAt,
        updatedAt,
        isEmailVerified,
        isActive,
        role,
      ];
}

enum UserRole {
  admin,
  user,
  guest,
}