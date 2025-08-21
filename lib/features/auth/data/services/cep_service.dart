import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  /// Busca endereço pelo CEP usando a API ViaCEP
  static Future<AddressModel?> fetchAddress(String cep) async {
    return fetchAddressByCep(cep);
  }
  
  /// Busca endereço pelo CEP usando a API ViaCEP
  static Future<AddressModel?> fetchAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleanCep.length != 8) {
        return null;
      }

      final url = Uri.parse('$_baseUrl/$cleanCep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verifica se o CEP retornou erro
        if (data['erro'] == true) {
          return null;
        }
        
        return AddressModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Erro ao buscar CEP: $e');
      return null;
    }
  }

  /// Valida se o CEP tem o formato correto
  static bool isValidCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8;
  }

  /// Formata o CEP para exibição (00000-000)
  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }
}