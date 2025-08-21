import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/profile_selection_screen.dart';
import '../../features/auth/presentation/screens/unified_registration_screen.dart';
import '../../features/auth/data/models/user_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String profileSelection = '/profile-selection';
  static const String registration = '/registration';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(
          const SplashScreen(),
          settings: settings,
        );
      
      case welcome:
        return _createRoute(
          const WelcomeScreen(),
          settings: settings,
        );
      
      case login:
        return _createRoute(
          const LoginScreen(),
          settings: settings,
        );
      
      case profileSelection:
        return _createRoute(
          const ProfileSelectionScreen(),
          settings: settings,
        );
      
      case registration:
        final userType = settings.arguments as UserType?;
        if (userType == null) {
          return _createRoute(
            const ProfileSelectionScreen(),
            settings: settings,
          );
        }
        return _createRoute(
          UnifiedRegistrationScreen(userType: userType),
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

  // Helper method to create routes with custom transitions
  static Route<dynamic> _createRoute(
    Widget page, {
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
