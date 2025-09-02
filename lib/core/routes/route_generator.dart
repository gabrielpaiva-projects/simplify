import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/client_registration_screen.dart';
import '../../features/auth/presentation/screens/professional_registration_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/services/presentation/screens/payment_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'route_arguments.dart';

/// Route generator for handling navigation
class RouteGenerator {
  /// Generate route based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get route arguments if any
    final args = settings.arguments as RouteArguments?;

    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return _buildRoute(
          const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.clientRegistration:
        return _buildRoute(
          const ClientRegistrationScreen(),
          settings: settings,
        );

      case AppRoutes.professionalRegistration:
        return _buildRoute(
          const ProfessionalRegistrationScreen(),
          settings: settings,
        );

      case AppRoutes.services:
        return _buildRoute(
          const ServicesScreen(),
          settings: settings,
        );

      case AppRoutes.payment:
        if (args != null && args.data != null) {
          return _buildRoute(
            PaymentScreen(
              serviceId: args.data['serviceId'] as String,
              bookingData: args.data['bookingData'] as Map<String, dynamic>,
            ),
            settings: settings,
          );
        }
        return _errorRoute('Payment requires service information');

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Build a material page route
  static MaterialPageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Build an error route
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}