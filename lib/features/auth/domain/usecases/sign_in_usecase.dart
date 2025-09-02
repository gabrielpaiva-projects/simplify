import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for signing in a user
class SignInUseCase extends UseCase<UserEntity, SignInParams> {
  final AuthRepositoryInterface repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    // Validate input parameters
    if (params.email.isEmpty || !_isValidEmail(params.email)) {
      return Left(ValidationFailure('Invalid email address'));
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Left(ValidationFailure('Password must be at least 6 characters'));
    }

    // Attempt to sign in
    return await repository.signInWithEmailAndPassword(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Parameters for sign in use case
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}