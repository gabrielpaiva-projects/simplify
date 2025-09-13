import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/services/presentation/screens/appointments_screen.dart';
import '../../features/services/presentation/screens/payment_details_screen.dart';
import '../../features/services/presentation/screens/appointment_details_screen.dart';
import '../../features/professional/presentation/screens/professional_home_screen.dart';
import '../../models/payment_pix_model.dart';
import '../../models/appointment_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String services = '/services';
  static const String professionalHome = '/professional-home';
  static const String appointments = '/appointments';
  static const String paymentDetails = '/payment-details';
  static const String appointmentDetails = '/appointment-details';

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
      
      case services:
        return MaterialPageRoute(
          builder: (_) => const ServicesScreen(),
          settings: settings,
        );
      
      case professionalHome:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalHomeScreen(),
          settings: settings,
        );
      
      case appointments:
        return MaterialPageRoute(
          builder: (_) => const AppointmentsScreen(),
          settings: settings,
        );
      
      case paymentDetails:
        final payment = settings.arguments as PaymentPixModel;
        return MaterialPageRoute(
          builder: (_) => PaymentDetailsScreen(payment: payment),
          settings: settings,
        );
      
      case appointmentDetails:
        final appointment = settings.arguments as AppointmentModel;
        return MaterialPageRoute(
          builder: (_) => AppointmentDetailsScreen(appointment: appointment),
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