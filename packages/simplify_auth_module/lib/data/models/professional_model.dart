import 'dart:convert';

/// Modelo de dados para Profissional
class ProfessionalModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? cpf;
  final String? cnpj;
  final String profession;
  final String? registrationNumber;
  final String? specialty;
  final List<String>? services;
  final String? bio;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? profileImage;
  final List<String>? certificates;
  final double? rating;
  final int? totalReviews;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfessionalModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cpf,
    this.cnpj,
    required this.profession,
    this.registrationNumber,
    this.specialty,
    this.services,
    this.bio,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.profileImage,
    this.certificates,
    this.rating,
    this.totalReviews,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'cpf': cpf,
      'cnpj': cnpj,
      'profession': profession,
      'registrationNumber': registrationNumber,
      'specialty': specialty,
      'services': services,
      'bio': bio,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'profileImage': profileImage,
      'certificates': certificates,
      'rating': rating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ProfessionalModel.fromMap(Map<String, dynamic> map) {
    return ProfessionalModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      cpf: map['cpf'],
      cnpj: map['cnpj'],
      profession: map['profession'] ?? '',
      registrationNumber: map['registrationNumber'],
      specialty: map['specialty'],
      services: map['services'] != null 
          ? List<String>.from(map['services']) 
          : null,
      bio: map['bio'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      profileImage: map['profileImage'],
      certificates: map['certificates'] != null 
          ? List<String>.from(map['certificates']) 
          : null,
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews']?.toInt(),
      isVerified: map['isVerified'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfessionalModel.fromJson(String source) => 
      ProfessionalModel.fromMap(json.decode(source));

  ProfessionalModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    String? cnpj,
    String? profession,
    String? registrationNumber,
    String? specialty,
    List<String>? services,
    String? bio,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? profileImage,
    List<String>? certificates,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessionalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      profession: profession ?? this.profession,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      specialty: specialty ?? this.specialty,
      services: services ?? this.services,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      profileImage: profileImage ?? this.profileImage,
      certificates: certificates ?? this.certificates,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}