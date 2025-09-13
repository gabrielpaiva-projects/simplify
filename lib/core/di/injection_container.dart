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

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // External dependencies
  await _initExternal();
  
  // Core
  _initCore();
  
  // Features
  _initFeatures();
}

void _initCore() {
  // Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl(),
      logger: sl(),
    ),
  );
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  
  // Logger
  sl.registerLazySingleton<LoggerService>(
    () => LoggerService(sl()),
  );
  
  // Firebase Messaging
  sl.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );
  
  // Notification Overlay
  sl.registerLazySingleton<NotificationOverlayService>(
    () => NotificationOverlayService(),
  );
}

void _initFeatures() {
  // Auth feature
  _initAuth();
}

void _initAuth() {
  // Services
  sl.registerLazySingleton<CepService>(
    () => CepService(),
  );
  
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: sl(),
    ),
  );
  
  // Providers
  sl.registerFactory<AuthProvider>(
    () => AuthProvider(
      authRepository: sl(),
    ),
  );
}

Future<void> _initExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Dio
  sl.registerLazySingleton(() => Dio());
  
  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
  
  // Logger
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