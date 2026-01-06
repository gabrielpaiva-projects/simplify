import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  static Future<AddressModel?> fetchAddressByCep(String cep) async {
    try {
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      print('[CepService] CEP recebido: $cep');
      print('[CepService] CEP limpo: $cleanCep');
      
      if (cleanCep.length != 8) {
        print('[CepService] CEP inválido - deve ter 8 dígitos');
        return null;
      }

      final url = Uri.parse('$_baseUrl/$cleanCep/json/');
      print('[CepService] URL da API: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[CepService] Timeout na requisição');
          throw Exception('Timeout ao buscar CEP');
        },
      );
      
      print('[CepService] Status Code: ${response.statusCode}');
      print('[CepService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[CepService] JSON decodificado: $data');
        
        if (data['erro'] == true) {
          print('[CepService] CEP não existe na base da ViaCEP');
          return null;
        }
        
        final address = AddressModel.fromJson(data);
        print('[CepService] AddressModel criado com sucesso');
        return address;
      } else {
        print('[CepService] Erro HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('[CepService] Erro ao buscar CEP: $e');
      print('[CepService] Stack trace: $stackTrace');
      return null;
    }
  }

  static bool isValidCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8;
  }

  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }
}