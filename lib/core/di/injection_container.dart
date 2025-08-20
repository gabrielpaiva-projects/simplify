import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/mock_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../network/network_info.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // External Dependencies
  await _initExternalDependencies();
  
  // Core
  _initCore();
  
  // Data Sources
  _initDataSources();
  
  // Repositories
  _initRepositories();
  
  // Use Cases
  _initUseCases();
  
  // BLoCs
  _initBlocs();
}

Future<void> _initExternalDependencies() async {
  // Dio
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.simplify.com',
        ),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
  );

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );
}

void _initCore() {
  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );
}

void _initDataSources() {
  // Remote Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(), // Usando mock por enquanto
  );

  // Local Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<FlutterSecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );
}

void _initRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
      getIt<NetworkInfo>(),
    ),
  );
}

void _initUseCases() {
  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => CheckAuthStatusUseCase(getIt<AuthRepository>()));
}

void _initBlocs() {
  // Auth BLoC
  getIt.registerFactory(
    () => AuthBloc(
      getIt<LoginUseCase>(),
      getIt<LogoutUseCase>(),
      getIt<CheckAuthStatusUseCase>(),
      getIt<AuthRepository>(),
    ),
  );
}