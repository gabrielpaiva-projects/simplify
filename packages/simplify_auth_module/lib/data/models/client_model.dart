import 'dart:convert';

/// Modelo de dados para Cliente
class ClientModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? cpf;
  final DateTime? birthDate;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cpf,
    this.birthDate,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.profileImage,
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
      'birthDate': birthDate?.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      cpf: map['cpf'],
      birthDate: map['birthDate'] != null 
          ? DateTime.parse(map['birthDate']) 
          : null,
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ClientModel.fromJson(String source) => 
      ClientModel.fromMap(json.decode(source));

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    DateTime? birthDate,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}