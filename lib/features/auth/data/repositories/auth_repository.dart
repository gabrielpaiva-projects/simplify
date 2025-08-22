import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

abstract class AuthRepository {
  Future<Either<String, UserCredential?>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, UserCredential?>> signUpClient({
    required ClientModel client,
  });

  Future<Either<String, UserCredential?>> signUpProfessional({
    required ProfessionalModel professional,
  });

  Future<Either<String, void>> signOut();

  Future<Either<String, void>> resetPassword(String email);

  Future<Either<String, Map<String, dynamic>?>> getUserData(String uid);

  Future<Either<String, UserType?>> getUserType(String uid);

  Future<Either<String, bool>> isEmailInUse(String email);

  Future<Either<String, bool>> isCpfInUse(String cpf);

  Future<Either<String, bool>> isProfessionalVerified(String uid);

  Future<Either<String, void>> verifyProfessional(String professionalUid, bool verified);

  Future<Either<String, List<Map<String, dynamic>>>> getUnverifiedProfessionals();

  Stream<User?> get authStateChanges;

  User? get currentUser;

  bool get isAuthenticated;

  String? get currentUserId;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl({required FirebaseAuthService authService})
      : _authService = authService;

  @override
  Future<Either<String, UserCredential?>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserCredential?>> signUpClient({
    required ClientModel client,
  }) async {
    try {
      // Verificar se email já está em uso
      final emailInUse = await _authService.isEmailInUse(client.email);
      if (emailInUse) {
        return const Left('Este email já está cadastrado');
      }

      // Verificar se CPF já está cadastrado
      final cpfInUse = await _authService.isCpfInUse(client.cpf);
      if (cpfInUse) {
        return const Left('Este CPF já está cadastrado');
      }

      final credential = await _authService.createClientAccount(
        client: client,
      );
      return Right(credential);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserCredential?>> signUpProfessional({
    required ProfessionalModel professional,
  }) async {
    try {
      // Verificar se email já está em uso
      final emailInUse = await _authService.isEmailInUse(professional.email);
      if (emailInUse) {
        return const Left('Este email já está cadastrado');
      }

      // Verificar se CPF já está cadastrado
      final cpfInUse = await _authService.isCpfInUse(professional.cpf);
      if (cpfInUse) {
        return const Left('Este CPF já está cadastrado');
      }

      final credential = await _authService.createProfessionalAccount(
        professional: professional,
      );
      return Right(credential);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>?>> getUserData(String uid) async {
    try {
      final data = await _authService.getUserData(uid);
      return Right(data);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserType?>> getUserType(String uid) async {
    try {
      final type = await _authService.getUserType(uid);
      return Right(type);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> isEmailInUse(String email) async {
    try {
      final inUse = await _authService.isEmailInUse(email);
      return Right(inUse);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> isCpfInUse(String cpf) async {
    try {
      final inUse = await _authService.isCpfInUse(cpf);
      return Right(inUse);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> isProfessionalVerified(String uid) async {
    try {
      final verified = await _authService.isProfessionalVerified(uid);
      return Right(verified);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> verifyProfessional(String professionalUid, bool verified) async {
    try {
      await _authService.verifyProfessional(professionalUid, verified);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getUnverifiedProfessionals() async {
    try {
      final professionals = await _authService.getUnverifiedProfessionals();
      return Right(professionals);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  String? get currentUserId => _authService.currentUserId;
}