import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Auth repository interface defining the contract for authentication operations
abstract class AuthRepositoryInterface {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up a new user
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? phoneNumber,
    String? cpf,
  });

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Get the current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    UserProfile? profile,
  });

  /// Reset password
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Verify email
  Future<Either<Failure, void>> verifyEmail();

  /// Update password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}