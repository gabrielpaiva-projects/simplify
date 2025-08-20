class ServerException implements Exception {
  final String? message;
  final String? code;
  
  const ServerException({
    this.message,
    this.code,
  });
}

class CacheException implements Exception {
  final String? message;
  
  const CacheException({
    this.message,
  });
}

class NetworkException implements Exception {
  final String? message;
  
  const NetworkException({
    this.message,
  });
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  
  const ValidationException({
    required this.message,
    this.errors,
  });
}

class UnauthorizedException implements Exception {
  final String? message;
  
  const UnauthorizedException({
    this.message,
  });
}

class NotFoundException implements Exception {
  final String? message;
  
  const NotFoundException({
    this.message,
  });
}