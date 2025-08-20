import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/auth_credentials.dart';
import '../../entities/auth_token.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class LoginUseCase extends UseCase<LoginResult, LoginParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Either<Failure, LoginResult>> call(LoginParams params) async {
    // Validações de negócio
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(message: 'E-mail é obrigatório'));
    }
    
    if (params.password.isEmpty) {
      return const Left(ValidationFailure(message: 'Senha é obrigatória'));
    }
    
    if (params.password.length < 8) {
      return const Left(
        ValidationFailure(message: 'A senha deve ter pelo menos 8 caracteres'),
      );
    }

    // Criar credenciais
    final credentials = AuthCredentials(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );

    // Realizar login
    final tokenResult = await _authRepository.login(credentials);
    
    return tokenResult.fold(
      (failure) => Left(failure),
      (token) async {
        // Salvar token se rememberMe for true
        if (params.rememberMe) {
          await _authRepository.saveToken(token);
        }
        
        // Obter usuário atual
        final userResult = await _authRepository.getCurrentUser();
        
        return userResult.fold(
          (failure) => Left(failure),
          (user) => Right(LoginResult(token: token, user: user)),
        );
      },
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LoginResult extends Equatable {
  final AuthToken token;
  final User? user;

  const LoginResult({
    required this.token,
    this.user,
  });

  @override
  List<Object?> get props => [token, user];
}