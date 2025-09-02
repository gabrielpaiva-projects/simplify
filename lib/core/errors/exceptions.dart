/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.data,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Server exception
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}

/// Cache exception
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}

/// Network exception
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
    this.errors,
  });
}

/// Authentication exception
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}

/// Permission exception
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}