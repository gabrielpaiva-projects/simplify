import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/logger_service.dart';
import '../utils/snackbar_utils.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Global error handler for the application
class ErrorHandler {
  final LoggerService _logger;

  ErrorHandler(this._logger);

  /// Handle exceptions and convert to failures
  Failure handleException(dynamic exception) {
    _logger.error('Exception occurred', exception);

    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    } else if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthException(exception);
    } else if (exception is FirebaseException) {
      return _handleFirebaseException(exception);
    } else {
      return UnknownFailure(
        exception.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Map app exceptions to failures
  Failure _mapAppExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        return ServerFailure(exception.message);
      case CacheException:
        return CacheFailure(exception.message);
      case NetworkException:
        return NetworkFailure(exception.message);
      case ValidationException:
        return ValidationFailure(exception.message);
      case AuthException:
        return AuthFailure(exception.message);
      case PermissionException:
        return PermissionFailure(exception.message);
      default:
        return UnknownFailure(exception.message);
    }
  }

  /// Handle Dio exceptions
  Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout. Please try again.');
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(exception.response);
      
      case DioExceptionType.cancel:
        return NetworkFailure('Request cancelled');
      
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection');
      
      default:
        return NetworkFailure('Network error occurred');
    }
  }

  /// Handle bad response from server
  Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return ServerFailure('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    String message = 'Server error occurred';

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return AuthFailure('Unauthorized access');
      case 403:
        return PermissionFailure('Permission denied');
      case 404:
        return ServerFailure('Resource not found');
      case 422:
        return ValidationFailure(message);
      case 500:
      case 502:
      case 503:
        return ServerFailure('Server error. Please try again later.');
      default:
        return ServerFailure(message);
    }
  }

  /// Handle Firebase Auth exceptions
  Failure _handleFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return AuthFailure('No user found with this email');
      case 'wrong-password':
        return AuthFailure('Invalid password');
      case 'email-already-in-use':
        return AuthFailure('Email is already registered');
      case 'invalid-email':
        return ValidationFailure('Invalid email address');
      case 'weak-password':
        return ValidationFailure('Password is too weak');
      case 'operation-not-allowed':
        return AuthFailure('Operation not allowed');
      case 'user-disabled':
        return AuthFailure('User account has been disabled');
      case 'too-many-requests':
        return AuthFailure('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return NetworkFailure('Network error. Please check your connection.');
      default:
        return AuthFailure(exception.message ?? 'Authentication error');
    }
  }

  /// Handle Firebase exceptions
  Failure _handleFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return PermissionFailure('Permission denied');
      case 'unavailable':
        return ServerFailure('Service temporarily unavailable');
      case 'cancelled':
        return ServerFailure('Operation cancelled');
      case 'unknown':
        return UnknownFailure('Unknown error occurred');
      case 'invalid-argument':
        return ValidationFailure('Invalid data provided');
      case 'not-found':
        return ServerFailure('Resource not found');
      case 'already-exists':
        return ServerFailure('Resource already exists');
      case 'resource-exhausted':
        return ServerFailure('Resource limit exceeded');
      default:
        return ServerFailure(exception.message ?? 'Firebase error');
    }
  }

  /// Show error to user
  void showError(BuildContext context, Failure failure) {
    final message = _getErrorMessage(failure);
    SnackbarUtils.showError(context, message);
    _logger.error('Showing error to user: $message');
  }

  /// Get user-friendly error message
  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message ?? 'Please check your internet connection';
    } else if (failure is ServerFailure) {
      return failure.message ?? 'Server error. Please try again later';
    } else if (failure is ValidationFailure) {
      return failure.message ?? 'Please check your input';
    } else if (failure is AuthFailure) {
      return failure.message ?? 'Authentication error';
    } else if (failure is PermissionFailure) {
      return failure.message ?? 'Permission denied';
    } else if (failure is CacheFailure) {
      return failure.message ?? 'Local storage error';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Log error with context
  void logError(
    String message, 
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _logger.error(
      message,
      error,
      stackTrace: stackTrace,
    );
    
    if (context != null) {
      _logger.debug('Error context: $context');
    }
  }
}