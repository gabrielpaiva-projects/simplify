import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';
import '../models/professional_model.dart';

/// Serviço de Registro/Cadastro
/// 
/// Responsável por gerenciar o cadastro de clientes e profissionais
class RegistrationService {
  static const String _baseUrl = 'https://api.simplify.com'; // URL da API

  /// Registra um novo cliente
  Future<ClientModel?> registerClient({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? cpf,
    DateTime? birthDate,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    File? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/auth/register/client'),
      );

      // Adiciona os campos do formulário
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      
      if (phone != null) request.fields['phone'] = phone;
      if (cpf != null) request.fields['cpf'] = cpf;
      if (birthDate != null) {
        request.fields['birthDate'] = birthDate.toIso8601String();
      }
      if (address != null) request.fields['address'] = address;
      if (city != null) request.fields['city'] = city;
      if (state != null) request.fields['state'] = state;
      if (zipCode != null) request.fields['zipCode'] = zipCode;

      // Adiciona a imagem de perfil se fornecida
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseData);
        return ClientModel.fromMap(data['client']);
      }

      return null;
    } catch (e) {
      print('Erro ao registrar cliente: $e');
      return null;
    }
  }

  /// Registra um novo profissional
  Future<ProfessionalModel?> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String profession,
    String? phone,
    String? cpf,
    String? cnpj,
    String? registrationNumber,
    String? specialty,
    List<String>? services,
    String? bio,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    File? profileImage,
    List<File>? certificates,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/auth/register/professional'),
      );

      // Adiciona os campos do formulário
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['profession'] = profession;
      
      if (phone != null) request.fields['phone'] = phone;
      if (cpf != null) request.fields['cpf'] = cpf;
      if (cnpj != null) request.fields['cnpj'] = cnpj;
      if (registrationNumber != null) {
        request.fields['registrationNumber'] = registrationNumber;
      }
      if (specialty != null) request.fields['specialty'] = specialty;
      if (services != null) {
        request.fields['services'] = json.encode(services);
      }
      if (bio != null) request.fields['bio'] = bio;
      if (address != null) request.fields['address'] = address;
      if (city != null) request.fields['city'] = city;
      if (state != null) request.fields['state'] = state;
      if (zipCode != null) request.fields['zipCode'] = zipCode;

      // Adiciona a imagem de perfil se fornecida
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
          ),
        );
      }

      // Adiciona os certificados se fornecidos
      if (certificates != null) {
        for (int i = 0; i < certificates.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'certificates[$i]',
              certificates[i].path,
            ),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseData);
        return ProfessionalModel.fromMap(data['professional']);
      }

      return null;
    } catch (e) {
      print('Erro ao registrar profissional: $e');
      return null;
    }
  }

  /// Verifica se um email já está cadastrado
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-email?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available'] == true;
      }

      return false;
    } catch (e) {
      print('Erro ao verificar email: $e');
      return false;
    }
  }

  /// Verifica se um CPF já está cadastrado
  Future<bool> checkCpfAvailability(String cpf) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-cpf?cpf=$cpf'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available'] == true;
      }

      return false;
    } catch (e) {
      print('Erro ao verificar CPF: $e');
      return false;
    }
  }

  /// Verifica se um CNPJ já está cadastrado
  Future<bool> checkCnpjAvailability(String cnpj) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-cnpj?cnpj=$cnpj'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available'] == true;
      }

      return false;
    } catch (e) {
      print('Erro ao verificar CNPJ: $e');
      return false;
    }
  }

  /// Valida o número de registro profissional
  Future<bool> validateProfessionalRegistration({
    required String registrationNumber,
    required String profession,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/validate-registration'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'registrationNumber': registrationNumber,
          'profession': profession,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao validar registro profissional: $e');
      return false;
    }
  }
}