/// Auth Module - Módulo de Autenticação
/// 
/// Este módulo contém toda a funcionalidade relacionada a autenticação,
/// incluindo login, cadastro de clientes e profissionais.
library auth_module;

// Presentation Layer - Screens
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/client_registration_screen.dart';
export 'presentation/screens/professional_registration_screen.dart';
export 'presentation/screens/modern_client_registration.dart';
export 'presentation/screens/modern_professional_registration.dart';
export 'presentation/screens/professional_analysis_screen.dart';

// Presentation Layer - Widgets
export 'presentation/widgets/auth_widgets.dart';

// Data Layer - Models
export 'data/models/user_model.dart';
export 'data/models/client_model.dart';
export 'data/models/professional_model.dart';

// Data Layer - Services
export 'data/services/auth_service.dart';
export 'data/services/registration_service.dart';

// Routes
export 'routes/auth_routes.dart';