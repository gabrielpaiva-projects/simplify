import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart' as di;
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure environment
  AppConfig.setEnvironment(Environment.development);
  
  // Initialize dependencies
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add your providers here as you refactor each feature
        // Example:
        // ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
      ],
      child: MaterialApp(
        title: 'Simplify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // Usando tema escuro por padrão
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        home: const SplashScreen(),
      ),
    );
  }
}
