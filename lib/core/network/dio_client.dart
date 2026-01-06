import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../utils/logger_service.dart';

class DioClient {
  final Dio _dio;
  final LoggerService _logger;

  DioClient({
    required Dio dio,
    required LoggerService logger,
  })  : _dio = dio,
        _logger = logger {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
          _logger.debug('Headers: ${options.headers}');
          _logger.debug('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.debug('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          _logger.debug('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.error('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          _logger.error('Message: ${error.message}');
          _logger.error('Response: ${error.response?.data}');
          
          final customError = _handleError(error);
          return handler.reject(customError);
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          message: 'Tempo de conexão esgotado',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Erro de conexão com o servidor',
          code: 'CONNECTION_ERROR',
        );
      case DioExceptionType.badResponse:
        throw _handleBadResponse(error);
      case DioExceptionType.cancel:
        throw AppException(
          message: 'Requisição cancelada',
          code: 'CANCELLED',
        );
      default:
        throw NetworkException(
          message: 'Erro desconhecido de rede',
          code: 'UNKNOWN',
        );
    }
  }

  Exception _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    
    String message = 'Erro no servidor';
    String? code;
    
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      code = data['code']?.toString();
    }
    
    if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 422) {
        return ValidationException(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          errors: data is Map<String, dynamic> ? data['errors'] : null,
        );
      }
      return ServerException(
        message: message,
        code: code ?? 'CLIENT_ERROR',
      );
    } else if (statusCode >= 500) {
      return ServerException(
        message: 'Erro interno do servidor',
        code: code ?? 'SERVER_ERROR',
      );
    }
    
    return ServerException(
      message: message,
      code: code ?? 'UNKNOWN_ERROR',
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}