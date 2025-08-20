import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, AuthToken>> login(AuthCredentials credentials) async {
    try {
      // Verificar conexão
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      // Fazer login remoto
      final tokenModel = await _remoteDataSource.login(
        email: credentials.email,
        password: credentials.password,
      );

      // Salvar token se rememberMe
      if (credentials.rememberMe) {
        await _localDataSource.saveToken(tokenModel);
        await _localDataSource.saveRememberMe(true);
      }

      return Right(tokenModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Obter token atual
      final token = await _localDataSource.getToken();
      
      // Se houver token e conexão, fazer logout remoto
      if (token != null && await _networkInfo.isConnected) {
        await _remoteDataSource.logout(token.accessToken);
      }

      // Limpar dados locais
      await _localDataSource.deleteToken();
      await _localDataSource.deleteUser();
      await _localDataSource.saveRememberMe(false);

      return const Right(null);
    } catch (e) {
      // Mesmo com erro, limpar dados locais
      await _localDataSource.deleteToken();
      await _localDataSource.deleteUser();
      
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
    String? phone,
  }) async {
    try {
      // Verificar conexão
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      // Registrar usuário
      final userModel = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      // Salvar usuário localmente
      await _localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      // Verificar conexão
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
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
      // Verificar conexão
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await _localDataSource.getToken();
      
      if (token == null) {
        return const Right(false);
      }

      // Verificar se o token não está expirado
      final isValid = !token.toEntity().isExpired;
      
      // Se expirou e tem refresh token, tentar renovar
      if (!isValid && token.refreshToken != null) {
        final refreshResult = await refreshToken();
        return refreshResult.fold(
          (_) => const Right(false),
          (_) => const Right(true),
        );
      }

      return Right(isValid);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Primeiro tentar obter do cache
      final cachedUser = await _localDataSource.getUser();
      
      if (cachedUser != null) {
        // Se houver conexão, atualizar do servidor
        if (await _networkInfo.isConnected) {
          final token = await _localDataSource.getToken();
          if (token != null) {
            try {
              final userModel = await _remoteDataSource.getCurrentUser(
                token.accessToken,
              );
              await _localDataSource.saveUser(userModel);
              return Right(userModel.toEntity());
            } catch (_) {
              // Se falhar, retornar o cache
              return Right(cachedUser.toEntity());
            }
          }
        }
        return Right(cachedUser.toEntity());
      }

      // Se não houver cache, buscar do servidor
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      final token = await _localDataSource.getToken();
      if (token == null) {
        return const Right(null);
      }

      final userModel = await _remoteDataSource.getCurrentUser(
        token.accessToken,
      );
      await _localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    try {
      // Verificar conexão
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet',
        ));
      }

      // Obter refresh token
      final currentToken = await _localDataSource.getToken();
      if (currentToken == null || currentToken.refreshToken == null) {
        return const Left(AuthenticationFailure(
          message: 'Token de renovação não encontrado',
        ));
      }

      // Renovar token
      final newToken = await _remoteDataSource.refreshToken(
        currentToken.refreshToken!,
      );

      // Salvar novo token
      await _localDataSource.saveToken(newToken);

      return Right(newToken.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Erro no servidor',
        code: e.statusCode?.toString(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message ?? 'Erro de rede',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveToken(AuthToken token) async {
    try {
      final tokenModel = AuthTokenModel.fromEntity(token);
      await _localDataSource.saveToken(tokenModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message ?? 'Erro ao salvar token',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteToken() async {
    try {
      await _localDataSource.deleteToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message ?? 'Erro ao deletar token',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getToken() async {
    try {
      final tokenModel = await _localDataSource.getToken();
      return Right(tokenModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message ?? 'Erro ao obter token',
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
}