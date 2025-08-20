import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Configure dependency injection
  await configureDependencies();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Simplify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Usando tema escuro por padrão
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const SplashScreen(),
    );
  }
}
