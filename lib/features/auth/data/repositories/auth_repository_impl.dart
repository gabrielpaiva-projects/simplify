import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final AuthInterceptor _authInterceptor;
  
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._authInterceptor,
  );
  
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      
      // Save tokens
      await _authInterceptor.saveTokens(
        token: response.token,
        refreshToken: response.refreshToken,
      );
      
      // Save user locally
      await _localDataSource.saveUser(response.user);
      
      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Login failed',
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Network error occurred',
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      
      // Save tokens
      await _authInterceptor.saveTokens(
        token: response.token,
        refreshToken: response.refreshToken,
      );
      
      // Save user locally
      await _localDataSource.saveUser(response.user);
      
      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Registration failed',
        code: e.code,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Network error occurred',
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _authInterceptor.clearTokens();
      await _localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      // Even if remote logout fails, clear local data
      await _authInterceptor.clearTokens();
      await _localDataSource.clearUser();
      return const Right(null);
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from local first
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }
      
      // If not found locally, fetch from remote
      final remoteUser = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(remoteUser);
      return Right(remoteUser.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to get user',
        code: e.code,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message ?? 'No cached user found',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to send reset email',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to reset password',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final hasToken = await _authInterceptor.hasValidToken();
      if (!hasToken) {
        return const Right(false);
      }
      
      // Verify token with server
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(user);
      return const Right(true);
    } catch (e) {
      return const Right(false);
    }
  }
  
  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      await _localDataSource.saveUser(updatedUser);
      return Right(updatedUser.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to update profile',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to change password',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> verifyEmail({
    required String token,
  }) async {
    try {
      await _remoteDataSource.verifyEmail(token: token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to verify email',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      await _remoteDataSource.resendVerificationEmail();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Failed to resend verification email',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
  
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timeout',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'No internet connection',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Server error';
        
        if (statusCode == 401) {
          return UnauthorizedFailure(message: message);
        } else if (statusCode == 404) {
          return NotFoundFailure(message: message);
        } else if (statusCode == 422) {
          return ValidationFailure(message: message);
        } else {
          return ServerFailure(
            message: message,
            code: statusCode?.toString(),
          );
        }
      default:
        return UnknownFailure(
          message: error.message ?? 'An error occurred',
        );
    }
  }
}