import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/client_model.dart';
import '../models/professional_model.dart';

/// Serviço de Autenticação
/// 
/// Responsável por gerenciar login, logout e sessão do usuário
class AuthService {
  static const String _baseUrl = 'https://api.simplify.com'; // URL da API
  String? _token;
  UserModel? _currentUser;

  // Getters
  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  /// Realiza o login do usuário
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = UserModel.fromMap(data['user']);
        
        // Salvar token localmente (implementar com shared_preferences)
        await _saveToken(_token!);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  /// Realiza o logout do usuário
  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      print('Erro no logout: $e');
    } finally {
      _token = null;
      _currentUser = null;
      await _clearToken();
    }
  }

  /// Verifica se o token ainda é válido
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = UserModel.fromMap(data['user']);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erro ao validar token: $e');
      return false;
    }
  }

  /// Recuperação de senha
  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao resetar senha: $e');
      return false;
    }
  }

  /// Atualiza a senha do usuário
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/update-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar senha: $e');
      return false;
    }
  }

  /// Salva o token localmente (implementar com shared_preferences)
  Future<void> _saveToken(String token) async {
    // TODO: Implementar salvamento com shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('auth_token', token);
  }

  /// Limpa o token salvo localmente
  Future<void> _clearToken() async {
    // TODO: Implementar limpeza com shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('auth_token');
  }

  /// Carrega o token salvo localmente
  Future<String?> loadSavedToken() async {
    // TODO: Implementar carregamento com shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('auth_token');
    return null;
  }
}