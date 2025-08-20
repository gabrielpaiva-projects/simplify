import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: 'auth_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      throw AuthenticationException(
        message: 'Sessão expirada. Por favor, faça login novamente.',
      );
    } else if (err.response?.statusCode == 403) {
      throw AuthorizationException(
        message: 'Você não tem permissão para acessar este recurso.',
      );
    }
    
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          message: 'Tempo de conexão excedido. Verifique sua internet.',
        );
      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Erro de conexão. Verifique sua internet.',
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data['message'] ?? 'Erro no servidor';
        
        if (statusCode != null && statusCode >= 500) {
          throw ServerException(
            message: 'Erro no servidor. Tente novamente mais tarde.',
            statusCode: statusCode,
          );
        } else if (statusCode != null && statusCode >= 400) {
          throw ServerException(
            message: message,
            statusCode: statusCode,
          );
        }
        break;
      default:
        break;
    }
    
    handler.next(err);
  }
}