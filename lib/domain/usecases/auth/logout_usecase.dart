import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

@lazySingleton
class LogoutUseCase extends UseCase<void, NoParams> {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Realizar logout
    final result = await _authRepository.logout();
    
    // Limpar token local independente do resultado
    await _authRepository.deleteToken();
    
    return result;
  }
}