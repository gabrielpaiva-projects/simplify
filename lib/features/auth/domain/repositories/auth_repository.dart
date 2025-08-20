import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, User>> getCurrentUser();
  
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });
  
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  
  Future<Either<Failure, bool>> checkAuthStatus();
  
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? avatarUrl,
  });
  
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<Either<Failure, void>> verifyEmail({
    required String token,
  });
  
  Future<Either<Failure, void>> resendVerificationEmail();
}