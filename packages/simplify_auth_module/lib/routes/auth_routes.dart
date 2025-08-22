import 'package:flutter/material.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/client_registration_screen.dart';
import '../presentation/screens/professional_registration_screen.dart';
import '../presentation/screens/modern_client_registration.dart';
import '../presentation/screens/modern_professional_registration.dart';
import '../presentation/screens/professional_analysis_screen.dart';

/// Rotas do Módulo de Autenticação
class AuthModuleRoutes {
  // Nomes das rotas
  static const String login = '/auth/login';
  static const String clientRegistration = '/auth/register/client';
  static const String professionalRegistration = '/auth/register/professional';
  static const String modernClientRegistration = '/auth/register/modern-client';
  static const String modernProfessionalRegistration = '/auth/register/modern-professional';
  static const String professionalAnalysis = '/auth/professional-analysis';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  /// Mapa de rotas do módulo
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    clientRegistration: (_) => const ClientRegistrationScreen(),
    professionalRegistration: (_) => const ProfessionalRegistrationScreen(),
    modernClientRegistration: (_) => const ModernClientRegistration(),
    modernProfessionalRegistration: (_) => const ModernProfessionalRegistration(),
    professionalAnalysis: (_) => const ProfessionalAnalysisScreen(),
  };

  /// Gera rotas dinâmicas do módulo
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      
      case clientRegistration:
        return MaterialPageRoute(
          builder: (_) => const ClientRegistrationScreen(),
          settings: settings,
        );
      
      case professionalRegistration:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalRegistrationScreen(),
          settings: settings,
        );
      
      case modernClientRegistration:
        return MaterialPageRoute(
          builder: (_) => const ModernClientRegistration(),
          settings: settings,
        );
      
      case modernProfessionalRegistration:
        return MaterialPageRoute(
          builder: (_) => const ModernProfessionalRegistration(),
          settings: settings,
        );
      
      case professionalAnalysis:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalAnalysisScreen(),
          settings: settings,
        );
      
      default:
        return null;
    }
  }

  /// Navega para a tela de login
  static Future<T?> navigateToLogin<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, login);
  }

  /// Navega para a tela de login e remove todas as rotas anteriores
  static Future<T?> navigateToLoginAndClear<T>(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      login,
      (route) => false,
    );
  }

  /// Navega para o cadastro de cliente
  static Future<T?> navigateToClientRegistration<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, clientRegistration);
  }

  /// Navega para o cadastro moderno de cliente
  static Future<T?> navigateToModernClientRegistration<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, modernClientRegistration);
  }

  /// Navega para o cadastro de profissional
  static Future<T?> navigateToProfessionalRegistration<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, professionalRegistration);
  }

  /// Navega para o cadastro moderno de profissional
  static Future<T?> navigateToModernProfessionalRegistration<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, modernProfessionalRegistration);
  }

  /// Navega para a análise profissional
  static Future<T?> navigateToProfessionalAnalysis<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, professionalAnalysis);
  }
}