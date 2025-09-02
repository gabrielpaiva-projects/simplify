import 'package:equatable/equatable.dart';

/// User entity representing the core user data
/// This is a domain entity that is independent of any external framework
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserType userType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final UserProfile? profile;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.isActive = true,
    this.profile,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        userType,
        createdAt,
        updatedAt,
        isEmailVerified,
        isActive,
        profile,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    UserProfile? profile,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      profile: profile ?? this.profile,
    );
  }
}

/// User type enumeration
enum UserType {
  client,
  professional,
  admin,
}

/// User profile with additional information
class UserProfile extends Equatable {
  final String? phoneNumber;
  final String? cpf;
  final String? photoUrl;
  final AddressEntity? address;
  final ProfessionalInfo? professionalInfo;

  const UserProfile({
    this.phoneNumber,
    this.cpf,
    this.photoUrl,
    this.address,
    this.professionalInfo,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        cpf,
        photoUrl,
        address,
        professionalInfo,
      ];
}

/// Address entity
class AddressEntity extends Equatable {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const AddressEntity({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Brasil',
  });

  @override
  List<Object?> get props => [
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
        zipCode,
        country,
      ];
}

/// Professional specific information
class ProfessionalInfo extends Equatable {
  final List<String> services;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final List<String> certifications;
  final String? description;
  final Map<String, dynamic>? availability;

  const ProfessionalInfo({
    required this.services,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.certifications = const [],
    this.description,
    this.availability,
  });

  @override
  List<Object?> get props => [
        services,
        rating,
        totalReviews,
        isVerified,
        certifications,
        description,
        availability,
      ];
}