class ServerException implements Exception {
  final String? message;
  final int? statusCode;

  ServerException({this.message, this.statusCode});
}

class CacheException implements Exception {
  final String? message;

  CacheException({this.message});
}

class NetworkException implements Exception {
  final String? message;

  NetworkException({this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException({required this.message, this.errors});
}

class AuthenticationException implements Exception {
  final String? message;

  AuthenticationException({this.message});
}

class AuthorizationException implements Exception {
  final String? message;

  AuthorizationException({this.message});
}