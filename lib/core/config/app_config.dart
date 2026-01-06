enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static Environment get environment => _environment;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.simplify.com.br/api';
      case Environment.production:
        return 'https://api.simplify.com.br/api';
    }
  }
  
  static String get websocketUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://localhost:3000';
      case Environment.staging:
        return 'wss://staging-api.simplify.com.br';
      case Environment.production:
        return 'wss://api.simplify.com.br';
    }
  }
  
  static Duration get connectionTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }
  
  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  static bool get enableCrashlytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
      case Environment.production:
        return true;
    }
  }
  
  static String get googleMapsApiKey {
    switch (_environment) {
      case Environment.development:
        return 'DEV_GOOGLE_MAPS_API_KEY';
      case Environment.staging:
        return 'STAGING_GOOGLE_MAPS_API_KEY';
      case Environment.production:
        return 'PROD_GOOGLE_MAPS_API_KEY';
    }
  }
}