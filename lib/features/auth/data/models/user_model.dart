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
  final bool isBlocked;

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
    this.isBlocked = false,
  });

  Map<String, dynamic> toJson();
}

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

class ProfessionalModel extends UserModel {
  final String rg;
  final String? addressProofPath;
  final String? profileImageUrl;
  final bool isVerified;

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
    this.profileImageUrl,
    this.isVerified = false,
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
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
    };
  }
}

enum UserType {
  client,
  professional,
  admin,
}