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
    };
  }
}

// Modelo para Profissional
class ProfessionalModel extends UserModel {
  final String rg;
  final String? addressProofPath; // Caminho do comprovante de endereço

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
    };
  }
}

// Enum para tipo de usuário
enum UserType {
  client,
  professional,
  admin,
}