// Modelo base para usuário
abstract class UserModel {
  final String cpf;
  final String fullName;
  final String email;
  final String password;
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final UserType userType;
  final bool isBlocked; // Flag para bloquear conta

  UserModel({
    required this.cpf,
    required this.fullName,
    required this.email,
    required this.password,
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.userType,
    this.isBlocked = false, // Por padrão, conta não bloqueada
  });

  Map<String, dynamic> toJson();
}

// Modelo para Cliente
class ClientModel extends UserModel {
  ClientModel({
    required String cpf,
    required String fullName,
    required String email,
    required String password,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    bool isBlocked = false,
  }) : super(
          cpf: cpf,
          fullName: fullName,
          email: email,
          password: password,
          cep: cep,
          street: street,
          number: number,
          complement: complement,
          neighborhood: neighborhood,
          city: city,
          state: state,
          userType: UserType.client,
          isBlocked: isBlocked,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'fullName': fullName,
      'email': email,
      'password': password,
      'cep': cep,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'userType': 'client',
      'isBlocked': isBlocked,
    };
  }
}

// Modelo para Profissional
class ProfessionalModel extends UserModel {
  final String rg;
  final String? addressProofPath; // Caminho do comprovante de endereço
  final String? profilePhotoUrl; // URL da foto de perfil no Firebase Storage
  final bool isVerified; // Flag de verificação do profissional
  final bool isFaceVerified; // Flag de verificação facial

  ProfessionalModel({
    required String cpf,
    required String fullName,
    required this.rg,
    required String email,
    required String password,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    this.addressProofPath,
    this.profilePhotoUrl,
    this.isVerified = false, // Por padrão, profissional não verificado
    this.isFaceVerified = false, // Por padrão, face não verificada
    bool isBlocked = false,
  }) : super(
          cpf: cpf,
          fullName: fullName,
          email: email,
          password: password,
          cep: cep,
          street: street,
          number: number,
          complement: complement,
          neighborhood: neighborhood,
          city: city,
          state: state,
          userType: UserType.professional,
          isBlocked: isBlocked,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'fullName': fullName,
      'rg': rg,
      'email': email,
      'password': password,
      'cep': cep,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'userType': 'professional',
      'addressProofPath': addressProofPath,
      'profilePhotoUrl': profilePhotoUrl,
      'isVerified': isVerified,
      'isFaceVerified': isFaceVerified,
      'isBlocked': isBlocked,
    };
  }
  
  // Factory constructor para criar do JSON (útil ao buscar do Firestore)
  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      cpf: json['cpf'] ?? '',
      fullName: json['fullName'] ?? '',
      rg: json['rg'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      cep: json['cep'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      complement: json['complement'],
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      addressProofPath: json['addressProofPath'],
      profilePhotoUrl: json['profilePhotoUrl'],
      isVerified: json['isVerified'] ?? false,
      isFaceVerified: json['isFaceVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }
  
  // Método para criar uma cópia com modificações
  ProfessionalModel copyWith({
    String? cpf,
    String? fullName,
    String? rg,
    String? email,
    String? password,
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? addressProofPath,
    String? profilePhotoUrl,
    bool? isVerified,
    bool? isFaceVerified,
    bool? isBlocked,
  }) {
    return ProfessionalModel(
      cpf: cpf ?? this.cpf,
      fullName: fullName ?? this.fullName,
      rg: rg ?? this.rg,
      email: email ?? this.email,
      password: password ?? this.password,
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      addressProofPath: addressProofPath ?? this.addressProofPath,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isVerified: isVerified ?? this.isVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

// Enum para tipo de usuário
enum UserType {
  client,
  professional,
  admin,
}