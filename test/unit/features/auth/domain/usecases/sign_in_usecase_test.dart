import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplify/core/errors/failures.dart';
import 'package:simplify/features/auth/domain/entities/user_entity.dart';
import 'package:simplify/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:simplify/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository implements AuthRepositoryInterface {
  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email == 'test@test.com' && password == 'password123') {
      return Right(
        UserEntity(
          id: '1',
          email: email,
          name: 'Test User',
          userType: UserType.client,
          createdAt: DateTime.now(),
        ),
      );
    }
    return const Left(AuthFailure(message: 'Invalid credentials'));
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? phoneNumber,
    String? cpf,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    UserProfile? profile,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> verifyEmail() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() {
    throw UnimplementedError();
  }

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(null);
}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    test('should return user when credentials are valid', () async {
      // Arrange
      const params = SignInParams(
        email: 'test@test.com',
        password: 'password123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.email, 'test@test.com');
          expect(user.name, 'Test User');
        },
      );
    });

    test('should return ValidationFailure when email is invalid', () async {
      // Arrange
      const params = SignInParams(
        email: 'invalid-email',
        password: 'password123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Invalid email address');
        },
        (user) => fail('Should not return user'),
      );
    });

    test('should return ValidationFailure when password is too short', () async {
      // Arrange
      const params = SignInParams(
        email: 'test@test.com',
        password: '123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Password must be at least 6 characters');
        },
        (user) => fail('Should not return user'),
      );
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      const params = SignInParams(
        email: 'test@test.com',
        password: 'wrongpassword',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Invalid credentials');
        },
        (user) => fail('Should not return user'),
      );
    });
  });
}