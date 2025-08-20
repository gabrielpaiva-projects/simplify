import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_token.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Realiza login com email e senha
  Future<Either<Failure, AuthToken>> login(AuthCredentials credentials);
  
  /// Realiza logout do usuário
  Future<Either<Failure, void>> logout();
  
  /// Registra um novo usuário
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  
  /// Recupera senha por email
  Future<Either<Failure, void>> forgotPassword(String email);
  
  /// Reseta a senha com token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  
  /// Verifica se o usuário está autenticado
  Future<Either<Failure, bool>> isAuthenticated();
  
  /// Obtém o usuário atual
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Atualiza o token de autenticação
  Future<Either<Failure, AuthToken>> refreshToken();
  
  /// Salva o token localmente
  Future<Either<Failure, void>> saveToken(AuthToken token);
  
  /// Remove o token local
  Future<Either<Failure, void>> deleteToken();
  
  /// Obtém o token salvo
  Future<Either<Failure, AuthToken?>> getToken();
}