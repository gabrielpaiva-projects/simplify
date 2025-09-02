import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for signing up a new user
class SignUpUseCase extends UseCase<UserEntity, SignUpParams> {
  final AuthRepositoryInterface repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    // Validate input parameters
    if (params.email.isEmpty || !_isValidEmail(params.email)) {
      return Left(ValidationFailure('Invalid email address'));
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Left(ValidationFailure('Password must be at least 6 characters'));
    }

    if (params.name.isEmpty || params.name.length < 2) {
      return Left(ValidationFailure('Name must be at least 2 characters'));
    }

    if (params.cpf != null && !_isValidCPF(params.cpf!)) {
      return Left(ValidationFailure('Invalid CPF'));
    }

    if (params.phoneNumber != null && !_isValidPhone(params.phoneNumber!)) {
      return Left(ValidationFailure('Invalid phone number'));
    }

    // Attempt to sign up
    return await repository.signUp(
      email: params.email.trim().toLowerCase(),
      password: params.password,
      name: params.name.trim(),
      userType: params.userType,
      phoneNumber: params.phoneNumber,
      cpf: params.cpf,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidCPF(String cpf) {
    // Remove non-digits
    final cleanCPF = cpf.replaceAll(RegExp(r'[^\d]'), '');
    return cleanCPF.length == 11;
  }

  bool _isValidPhone(String phone) {
    // Remove non-digits
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 11;
  }
}

/// Parameters for sign up use case
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final UserType userType;
  final String? phoneNumber;
  final String? cpf;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
    this.phoneNumber,
    this.cpf,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        name,
        userType,
        phoneNumber,
        cpf,
      ];
}