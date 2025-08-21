import 'package:flutter/material.dart';
import 'package:simplify_auth_module/simplify_auth_module.dart';

void main() {
  // Initialize the auth module with custom configuration
  SimplifyAuthModule.initialize(
    baseUrl: 'https://your-api.com',
    useDarkTheme: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simplify Auth Module Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      // Option 1: Use the module's route generator
      onGenerateRoute: (settings) {
        // First check if it's an auth route
        final authRoute = SimplifyAuthModule.generateRoute(settings);
        if (authRoute != null) {
          return authRoute;
        }
        
        // Handle other app routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Route not found'),
                ),
              ),
            );
        }
      },
      
      // Option 2: Add auth routes to your app routes
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/dashboard': (context) => const DashboardScreen(),
      //   ...SimplifyAuthModule.getRoutes(),
      // },
      
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 32),
              const Text(
                'Simplify Auth Module',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Example Application',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 48),
              
              // Navigate to Login
              ElevatedButton(
                onPressed: () {
                  AuthModuleRoutes.navigateToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Navigate to Client Registration
              OutlinedButton(
                onPressed: () {
                  AuthModuleRoutes.navigateToModernClientRegistration(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Register as Client',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Navigate to Professional Registration
              OutlinedButton(
                onPressed: () {
                  AuthModuleRoutes.navigateToModernProfessionalRegistration(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Register as Professional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.deepBlack,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Welcome to Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}