import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';

/// Classe base para todos os casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe para casos de uso sem parâmetros
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}