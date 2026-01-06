import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../utils/logger_service.dart';
import '../../features/auth/data/services/cep_service.dart';
import '../../features/auth/data/services/firebase_auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/notification_overlay_service.dart';
import '../../services/notification_storage_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initExternal();
  
  _initCore();
  
  _initFeatures();
}

void _initCore() {
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl(),
      logger: sl(),
    ),
  );
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  
  sl.registerLazySingleton<LoggerService>(
    () => LoggerService(sl()),
  );
  
  sl.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );
  
  sl.registerLazySingleton<NotificationOverlayService>(
    () => NotificationOverlayService(),
  );
  
  sl.registerLazySingleton<NotificationStorageService>(
    () => NotificationStorageService(),
  );
}

void _initFeatures() {
  _initAuth();
}

void _initAuth() {
  sl.registerLazySingleton<CepService>(
    () => CepService(),
  );
  
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: sl(),
    ),
  );
  
  sl.registerFactory<AuthProvider>(
    () => AuthProvider(
      authRepository: sl(),
    ),
  );
}

Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => Dio());
  
  sl.registerLazySingleton(() => Connectivity());
  
  sl.registerLazySingleton(() => Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  ));
}