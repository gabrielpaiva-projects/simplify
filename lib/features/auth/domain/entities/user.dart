import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  bool get isEmailVerified => emailVerifiedAt != null;
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatarUrl,
    emailVerifiedAt,
    createdAt,
    updatedAt,
  ];
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}