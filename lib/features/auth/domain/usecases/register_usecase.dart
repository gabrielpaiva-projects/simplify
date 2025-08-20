import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository _repository;
  
  RegisterUseCase(this._repository);
  
  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await _repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });
  
  @override
  List<Object> get props => [email, password, name];
}