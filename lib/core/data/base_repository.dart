import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import '../utils/logger_service.dart';

abstract class BaseRepository {
  final NetworkInfo networkInfo;
  final LoggerService logger;

  BaseRepository({
    required this.networkInfo,
    required this.logger,
  });

  Future<Either<Failure, T>> executeRemote<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    final isConnected = await networkInfo.isConnected;
    
    if (!isConnected) {
      logger.warning('No internet connection for operation: ${operationName ?? 'unknown'}');
      return const Left(NetworkFailure(
        message: 'Sem conexão com a internet',
        code: 'NO_INTERNET',
      ));
    }

    try {
      logger.debug('Executing remote operation: ${operationName ?? 'unknown'}');
      final result = await operation();
      logger.debug('Remote operation successful: ${operationName ?? 'unknown'}');
      return Right(result);
    } on ServerException catch (e) {
      logger.error('Server exception in ${operationName ?? 'unknown'}: ${e.message}', e);
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on NetworkException catch (e) {
      logger.error('Network exception in ${operationName ?? 'unknown'}: ${e.message}', e);
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on ValidationException catch (e) {
      logger.error('Validation exception in ${operationName ?? 'unknown'}: ${e.message}', e);
      return Left(ValidationFailure(
        message: e.message,
        code: e.code,
        errors: e.errors,
      ));
    } catch (e, stackTrace) {
      logger.error('Unexpected error in ${operationName ?? 'unknown'}', e, stackTrace);
      return Left(UnknownFailure(
        message: 'Erro inesperado: ${e.toString()}',
      ));
    }
  }

  Future<Either<Failure, T>> executeLocal<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      logger.debug('Executing local operation: ${operationName ?? 'unknown'}');
      final result = await operation();
      logger.debug('Local operation successful: ${operationName ?? 'unknown'}');
      return Right(result);
    } on CacheException catch (e) {
      logger.error('Cache exception in ${operationName ?? 'unknown'}: ${e.message}', e);
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e, stackTrace) {
      logger.error('Unexpected error in ${operationName ?? 'unknown'}', e, stackTrace);
      return Left(UnknownFailure(
        message: 'Erro ao acessar dados locais: ${e.toString()}',
      ));
    }
  }

  Either<Failure, T> executeSync<T>(
    T Function() operation, {
    String? operationName,
  }) {
    try {
      logger.debug('Executing sync operation: ${operationName ?? 'unknown'}');
      final result = operation();
      logger.debug('Sync operation successful: ${operationName ?? 'unknown'}');
      return Right(result);
    } catch (e, stackTrace) {
      logger.error('Error in sync operation ${operationName ?? 'unknown'}', e, stackTrace);
      return Left(UnknownFailure(
        message: 'Erro na operação: ${e.toString()}',
      ));
    }
  }
}