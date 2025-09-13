import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart' as di;
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'services/firebase_messaging_service.dart';
import 'services/notification_overlay_service.dart';
import 'services/notification_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Configure environment
  AppConfig.setEnvironment(Environment.development);
  
  // Initialize dependencies
  await di.init();
  
  // Initialize Firebase Messaging Service
  final messagingService = di.sl<FirebaseMessagingService>();
  await messagingService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>(),
        ),
        // Notification Storage Provider
        ChangeNotifierProvider(
          create: (_) => di.sl<NotificationStorageService>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Simplify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // Usando tema escuro por padrão
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        home: OverlayWrapper(
          child: const SplashScreen(),
        ),
      ),
    );
  }
}

/// Widget wrapper que garante a inicialização correta do overlay service
class OverlayWrapper extends StatefulWidget {
  final Widget child;

  const OverlayWrapper({
    super.key,
    required this.child,
  });

  @override
  State<OverlayWrapper> createState() => _OverlayWrapperState();
}

class _OverlayWrapperState extends State<OverlayWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Inicializar o overlay service após o widget estar completamente montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final overlayService = di.sl<NotificationOverlayService>();
        overlayService.initialize(context);
        debugPrint('NotificationOverlayService initialized with context');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
