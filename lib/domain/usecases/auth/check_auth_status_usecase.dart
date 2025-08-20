import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class CheckAuthStatusUseCase extends UseCase<AuthStatus, NoParams> {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthStatus>> call(NoParams params) async {
    // Verificar se está autenticado
    final isAuthResult = await _authRepository.isAuthenticated();
    
    return isAuthResult.fold(
      (failure) => Left(failure),
      (isAuthenticated) async {
        if (!isAuthenticated) {
          return const Right(AuthStatus(isAuthenticated: false));
        }
        
        // Se está autenticado, obter o usuário
        final userResult = await _authRepository.getCurrentUser();
        
        return userResult.fold(
          (failure) => const Right(AuthStatus(isAuthenticated: false)),
          (user) => Right(AuthStatus(
            isAuthenticated: true,
            user: user,
          )),
        );
      },
    );
  }
}

class AuthStatus {
  final bool isAuthenticated;
  final User? user;

  const AuthStatus({
    required this.isAuthenticated,
    this.user,
  });
}