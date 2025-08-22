/// Simplify Auth Module
/// 
/// Um módulo completo de autenticação para aplicações Flutter.
/// Inclui funcionalidades de login, cadastro de clientes e profissionais.
library simplify_auth_module;

// Core exports
export 'core/constants/app_colors.dart';

// Presentation Layer - Screens
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/client_registration_screen.dart';
export 'presentation/screens/professional_registration_screen.dart';
export 'presentation/screens/modern_client_registration.dart';
export 'presentation/screens/modern_professional_registration.dart';
export 'presentation/screens/professional_analysis_screen.dart';

// Presentation Layer - Widgets
export 'presentation/widgets/auth_widgets.dart';
export 'presentation/widgets/modern_profile_selection_sheet.dart';
export 'presentation/widgets/profile_selection_bottom_sheet.dart';
export 'presentation/widgets/terms_and_conditions_step.dart';

// Data Layer - Models
export 'data/models/user_model.dart';
export 'data/models/client_model.dart';
export 'data/models/professional_model.dart';
export 'data/models/address_model.dart';

// Data Layer - Services
export 'data/services/auth_service.dart';
export 'data/services/registration_service.dart';
export 'data/services/cep_service.dart';

// Routes
export 'routes/auth_routes.dart';

// Configuration class for the module
class SimplifyAuthModule {
  static SimplifyAuthModule? _instance;
  
  // API Configuration
  String _baseUrl = 'https://api.simplify.com';
  
  // Theme Configuration
  bool _useDarkTheme = true;
  
  // Private constructor
  SimplifyAuthModule._();
  
  // Singleton instance
  static SimplifyAuthModule get instance {
    _instance ??= SimplifyAuthModule._();
    return _instance!;
  }
  
  // Initialize the module with custom configuration
  static void initialize({
    String? baseUrl,
    bool? useDarkTheme,
  }) {
    if (baseUrl != null) {
      instance._baseUrl = baseUrl;
    }
    if (useDarkTheme != null) {
      instance._useDarkTheme = useDarkTheme;
    }
  }
  
  // Getters
  String get baseUrl => _baseUrl;
  bool get useDarkTheme => _useDarkTheme;
  
  // Helper method to get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return AuthModuleRoutes.routes;
  }
  
  // Helper method to handle route generation
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return AuthModuleRoutes.generateRoute(settings);
  }
}