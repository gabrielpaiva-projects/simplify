import 'package:flutter/material.dart';
import 'package:simplify_auth_module/simplify_auth_module.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  // Initialize the auth module
  SimplifyAuthModule.initialize(
    baseUrl: 'https://api.simplify.com',
    useDarkTheme: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
