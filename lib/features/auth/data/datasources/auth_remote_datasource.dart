import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
// import 'package:retrofit/retrofit.dart';

import '../models/auth_response_model.dart';
import '../models/user_model.dart';

// part 'auth_remote_datasource.g.dart'; // Will be generated

// Temporary implementation until code generation
@lazySingleton
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
  
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  });
  
  Future<void> logout();
  
  Future<UserModel> getCurrentUser();
  
  Future<void> forgotPassword({
    required String email,
  });
  
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  });
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<void> verifyEmail({
    required String token,
  });
  
  Future<void> resendVerificationEmail();
}

// Temporary implementation
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  
  AuthRemoteDataSourceImpl(this._dio);
  
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponseModel.fromJson(response.data);
  }
  
  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return AuthResponseModel.fromJson(response.data);
  }
  
  @override
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data);
  }
  
  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }
  
  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post('/auth/reset-password', data: {
      'token': token,
      'password': newPassword,
    });
  }
  
  @override
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    final response = await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
    return UserModel.fromJson(response.data);
  }
  
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }
  
  @override
  Future<void> verifyEmail({
    required String token,
  }) async {
    await _dio.post('/auth/verify-email', data: {
      'token': token,
    });
  }
  
  @override
  Future<void> resendVerificationEmail() async {
    await _dio.post('/auth/resend-verification');
  }
}