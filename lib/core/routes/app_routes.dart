import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_registration_screen.dart';
import '../../features/auth/presentation/screens/profile_selection_screen.dart';
import '../../features/auth/presentation/screens/new_client_registration_screen.dart';
import '../../features/auth/presentation/screens/new_professional_registration_screen.dart';
import '../../features/auth/presentation/screens/registration_success_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String welcomeRegistration = '/welcome-registration';
  static const String profileSelection = '/profile-selection';
  static const String clientRegistration = '/client-registration';
  static const String professionalRegistration = '/professional-registration';
  static const String registrationSuccess = '/registration-success';
  static const String completeProfile = '/complete-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      
      case welcomeRegistration:
        return MaterialPageRoute(
          builder: (_) => const WelcomeRegistrationScreen(),
          settings: settings,
        );
      
      case profileSelection:
        return MaterialPageRoute(
          builder: (_) => const ProfileSelectionScreen(),
          settings: settings,
        );
      
      case clientRegistration:
        return MaterialPageRoute(
          builder: (_) => const NewClientRegistrationScreen(),
          settings: settings,
        );
      
      case professionalRegistration:
        return MaterialPageRoute(
          builder: (_) => const NewProfessionalRegistrationScreen(),
          settings: settings,
        );
      
      case registrationSuccess:
        return MaterialPageRoute(
          builder: (_) => const RegistrationSuccessScreen(),
          settings: settings,
        );
      
      case home:
      case completeProfile:
        // Placeholder para telas futuras
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF131313),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.construction,
                    size: 64,
                    color: Color(0xFF166F53),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Em construção',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.name ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
