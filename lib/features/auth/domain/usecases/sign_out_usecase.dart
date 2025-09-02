import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for signing out the current user
class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepositoryInterface repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}