class AppConstants {
  AppConstants._();
  
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const String apiVersion = '/v1';
  
  // App Configuration
  static const String appName = 'Simplify';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String firstLaunchKey = 'first_launch';
  static const String userKey = 'user_data';
  
  // Timeouts
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
}