class AppConstants {
  // App Info
  static const String appName = 'Simplify';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Simplificando sua limpeza e organização';
  
  // API
  static const String apiBaseUrl = 'https://api.simplify.com';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  static const String firstTimeKey = 'first_time';
  static const String rememberMeKey = 'remember_me';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int pageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const int cacheMaxSize = 100; // MB
  
  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  
  // Firebase Collections (para uso futuro)
  static const String usersCollection = 'users';
  static const String servicesCollection = 'services';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
}