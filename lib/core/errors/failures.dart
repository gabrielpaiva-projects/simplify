import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, stackTrace];

  @override
  String toString() => '$runtimeType: $message';
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    super.code,
    super.stackTrace,
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, stackTrace, errors];
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Um erro inesperado ocorreu',
    super.code,
    super.stackTrace,
  });
}