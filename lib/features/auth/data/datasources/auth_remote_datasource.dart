import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@lazySingleton
@RestApi()
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;
  
  @POST('/auth/login')
  Future<AuthResponseModel> login({
    @Field('email') required String email,
    @Field('password') required String password,
  });
  
  @POST('/auth/register')
  Future<AuthResponseModel> register({
    @Field('email') required String email,
    @Field('password') required String password,
    @Field('name') required String name,
  });
  
  @POST('/auth/logout')
  Future<void> logout();
  
  @GET('/auth/me')
  Future<UserModel> getCurrentUser();
  
  @POST('/auth/forgot-password')
  Future<void> forgotPassword({
    @Field('email') required String email,
  });
  
  @POST('/auth/reset-password')
  Future<void> resetPassword({
    @Field('token') required String token,
    @Field('password') required String newPassword,
  });
  
  @PUT('/auth/profile')
  Future<UserModel> updateProfile({
    @Field('name') String? name,
    @Field('avatar_url') String? avatarUrl,
  });
  
  @POST('/auth/change-password')
  Future<void> changePassword({
    @Field('current_password') required String currentPassword,
    @Field('new_password') required String newPassword,
  });
  
  @POST('/auth/verify-email')
  Future<void> verifyEmail({
    @Field('token') required String token,
  });
  
  @POST('/auth/resend-verification')
  Future<void> resendVerificationEmail();
}