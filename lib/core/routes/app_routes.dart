import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../modules/auth_module/auth_module.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Primeiro verifica se é uma rota do módulo de autenticação
    if (settings.name?.startsWith('/auth') ?? false) {
      final authRoute = AuthModuleRoutes.generateRoute(settings);
      if (authRoute != null) {
        return authRoute;
      }
    }

    // Rotas principais da aplicação
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      
      case login:
      case '/login':
        // Redireciona para a rota do módulo de autenticação
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Rota não encontrada'),
            ),
          ),
        );
    }
  }
}
