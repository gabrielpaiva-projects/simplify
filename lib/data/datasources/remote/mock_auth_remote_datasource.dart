import '../../../core/errors/exceptions.dart';
import '../../models/auth_token_model.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  // Simulação de banco de dados em memória
  final Map<String, Map<String, dynamic>> _users = {
    'user@example.com': {
      'id': '1',
      'email': 'user@example.com',
      'password': 'password123',
      'name': 'João Silva',
      'phone': '+55 11 98765-4321',
      'photoUrl': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isEmailVerified': true,
      'isActive': true,
      'role': 'user',
    },
    'admin@example.com': {
      'id': '2',
      'email': 'admin@example.com',
      'password': 'admin123',
      'name': 'Admin User',
      'phone': '+55 11 91234-5678',
      'photoUrl': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isEmailVerified': true,
      'isActive': true,
      'role': 'admin',
    },
  };

  String? _currentToken;
  String? _currentUserId;

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 2));

    final user = _users[email];
    
    if (user == null) {
      throw ServerException(
        message: 'Usuário não encontrado',
        statusCode: 404,
      );
    }

    if (user['password'] != password) {
      throw ServerException(
        message: 'Senha incorreta',
        statusCode: 401,
      );
    }

    // Gerar token mockado
    _currentToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = user['id'];
    
    return AuthTokenModel(
      accessToken: _currentToken!,
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      tokenType: 'Bearer',
    );
  }

  @override
  Future<void> logout(String token) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (token != _currentToken) {
      throw ServerException(
        message: 'Token inválido',
        statusCode: 401,
      );
    }
    
    _currentToken = null;
    _currentUserId = null;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 2));

    if (_users.containsKey(email)) {
      throw ServerException(
        message: 'E-mail já cadastrado',
        statusCode: 409,
      );
    }

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'photoUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isEmailVerified': false,
      'isActive': true,
      'role': 'user',
    };

    _users[email] = newUser;
    
    return UserModel(
      id: newUser['id'] as String,
      email: newUser['email'] as String,
      name: newUser['name'] as String,
      phone: newUser['phone'] as String?,
      photoUrl: newUser['photoUrl'] as String?,
      createdAt: DateTime.parse(newUser['createdAt'] as String),
      updatedAt: DateTime.parse(newUser['updatedAt'] as String),
      isEmailVerified: newUser['isEmailVerified'] as bool,
      isActive: newUser['isActive'] as bool,
      role: newUser['role'] as String,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    if (!_users.containsKey(email)) {
      throw ServerException(
        message: 'E-mail não cadastrado',
        statusCode: 404,
      );
    }

    // Simular envio de e-mail
    print('Mock: E-mail de recuperação enviado para $email');
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    // Simular validação de token
    if (!token.startsWith('reset_')) {
      throw ServerException(
        message: 'Token inválido',
        statusCode: 400,
      );
    }

    print('Mock: Senha resetada com sucesso');
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    if (token != _currentToken) {
      throw ServerException(
        message: 'Token inválido',
        statusCode: 401,
      );
    }

    // Encontrar usuário pelo ID atual
    final user = _users.values.firstWhere(
      (u) => u['id'] == _currentUserId,
      orElse: () => throw ServerException(
        message: 'Usuário não encontrado',
        statusCode: 404,
      ),
    );

    return UserModel(
      id: user['id'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
      phone: user['phone'] as String?,
      photoUrl: user['photoUrl'] as String?,
      createdAt: DateTime.parse(user['createdAt'] as String),
      updatedAt: DateTime.parse(user['updatedAt'] as String),
      isEmailVerified: user['isEmailVerified'] as bool,
      isActive: user['isActive'] as bool,
      role: user['role'] as String,
    );
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    if (!refreshToken.startsWith('mock_refresh_token_')) {
      throw ServerException(
        message: 'Refresh token inválido',
        statusCode: 401,
      );
    }

    // Gerar novo token
    _currentToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    
    return AuthTokenModel(
      accessToken: _currentToken!,
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      tokenType: 'Bearer',
    );
  }
}