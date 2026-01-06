class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.data,
  });
}

class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.data,
  });
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.data,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    super.code,
    super.data,
    this.errors,
  });
}