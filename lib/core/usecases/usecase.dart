import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base class for all use cases in the application
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when the use case doesn't need any parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];