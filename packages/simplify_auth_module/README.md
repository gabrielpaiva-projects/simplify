# Simplify Auth Module

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.0.0-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-orange)](pubspec.yaml)

Um módulo completo de autenticação para aplicações Flutter, oferecendo funcionalidades prontas para login, cadastro de clientes e profissionais com design moderno e animações fluidas.

## 🌟 Features

- ✅ **Tela de Login** completa com validações
- ✅ **Cadastro de Clientes** com múltiplos passos
- ✅ **Cadastro de Profissionais** com upload de documentos
- ✅ **Busca automática de CEP**
- ✅ **Máscaras de input** (CPF, CNPJ, telefone, CEP)
- ✅ **Validações em tempo real**
- ✅ **Indicador de força de senha**
- ✅ **Upload de imagens e documentos**
- ✅ **Animações e transições suaves**
- ✅ **Design moderno e responsivo**
- ✅ **Tema escuro por padrão**
- ✅ **Totalmente customizável**

## 📱 Screenshots

<table>
  <tr>
    <td>Login Screen</td>
    <td>Profile Selection</td>
    <td>Client Registration</td>
  </tr>
  <tr>
    <td><img src="screenshots/login.png" width="200"></td>
    <td><img src="screenshots/profile_selection.png" width="200"></td>
    <td><img src="screenshots/client_registration.png" width="200"></td>
  </tr>
</table>

## 🚀 Getting Started

### Installation

Adicione o `simplify_auth_module` ao seu `pubspec.yaml`:

```yaml
dependencies:
  simplify_auth_module: ^1.0.0
```

Ou use diretamente do GitHub:

```yaml
dependencies:
  simplify_auth_module:
    git:
      url: https://github.com/seu-usuario/simplify_auth_module.git
      ref: main
```

Ou use como package local:

```yaml
dependencies:
  simplify_auth_module:
    path: packages/simplify_auth_module
```

### Basic Usage

#### 1. Inicialize o módulo

```dart
import 'package:simplify_auth_module/simplify_auth_module.dart';

void main() {
  // Configure o módulo (opcional)
  SimplifyAuthModule.initialize(
    baseUrl: 'https://your-api.com',
    useDarkTheme: true,
  );
  
  runApp(MyApp());
}
```

#### 2. Configure as rotas

**Opção A: Use o gerador de rotas do módulo**

```dart
MaterialApp(
  onGenerateRoute: (settings) {
    // Primeiro verifica se é uma rota do módulo auth
    final authRoute = SimplifyAuthModule.generateRoute(settings);
    if (authRoute != null) {
      return authRoute;
    }
    
    // Suas outras rotas aqui
    // ...
  },
)
```

**Opção B: Adicione as rotas ao seu mapa de rotas**

```dart
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/dashboard': (context) => DashboardScreen(),
    ...SimplifyAuthModule.getRoutes(), // Adiciona todas as rotas do módulo
  },
)
```

#### 3. Navegue para as telas

```dart
// Navegar para login
AuthModuleRoutes.navigateToLogin(context);

// Navegar para cadastro de cliente
AuthModuleRoutes.navigateToModernClientRegistration(context);

// Navegar para cadastro de profissional
AuthModuleRoutes.navigateToModernProfessionalRegistration(context);

// Ou use Navigator com nome da rota
Navigator.pushNamed(context, '/auth/login');
```

## 📋 Available Screens

### Login Screen
- Email e senha
- Validações
- Link para recuperação de senha
- Botão para criar conta

### Client Registration
- **Passo 1**: Dados pessoais (nome, email, CPF, telefone)
- **Passo 2**: Senha e confirmação
- **Passo 3**: Endereço com busca de CEP

### Professional Registration
- **Passo 1**: Dados pessoais
- **Passo 2**: Dados profissionais
- **Passo 3**: Senha
- **Passo 4**: Endereço
- **Passo 5**: Upload de documentos

## 🛠️ Services

### AuthService

```dart
final authService = AuthService();

// Login
bool success = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Check authentication
if (authService.isAuthenticated) {
  // User is logged in
}

// Logout
await authService.logout();

// Reset password
await authService.resetPassword('user@example.com');
```

### RegistrationService

```dart
final registrationService = RegistrationService();

// Register client
final client = await registrationService.registerClient(
  name: 'João Silva',
  email: 'joao@example.com',
  password: 'senha123',
  phone: '(11) 98765-4321',
  cpf: '123.456.789-00',
);

// Register professional
final professional = await registrationService.registerProfessional(
  name: 'Dr. Maria Santos',
  email: 'maria@example.com',
  password: 'senha123',
  profession: 'Médica',
  registrationNumber: 'CRM-12345',
);

// Check email availability
bool available = await registrationService.checkEmailAvailability('email@example.com');
```

### CepService

```dart
final cepService = CepService();

// Search address by CEP
final address = await cepService.searchCep('01310-100');
if (address != null) {
  print(address.street); // Av. Paulista
  print(address.city);   // São Paulo
  print(address.state);  // SP
}
```

## 🎨 Customization

### Colors

O módulo usa a classe `AppColors` com as seguintes cores principais:

```dart
AppColors.primaryGreen    // Verde principal
AppColors.deepBlack       // Preto profundo
AppColors.charcoalGrey    // Cinza carvão
AppColors.secondaryText   // Texto secundário
```

### Theme

Você pode customizar o tema durante a inicialização:

```dart
SimplifyAuthModule.initialize(
  useDarkTheme: false, // Use light theme
);
```

## 📁 Project Structure

```
simplify_auth_module/
├── lib/
│   ├── simplify_auth_module.dart    # Main export file
│   ├── core/
│   │   └── constants/
│   │       └── app_colors.dart      # Color constants
│   ├── data/
│   │   ├── models/                  # Data models
│   │   └── services/                # API services
│   ├── presentation/
│   │   ├── screens/                 # All screens
│   │   └── widgets/                 # Reusable widgets
│   └── routes/
│       └── auth_routes.dart         # Route definitions
├── example/                         # Example app
├── test/                           # Unit tests
├── pubspec.yaml
└── README.md
```

## 🧪 Testing

Run the tests:

```bash
flutter test
```

Run the example app:

```bash
cd example
flutter run
```

## 📝 Requirements

- Flutter SDK: ^3.0.0
- Dart SDK: ^3.0.0

## 📦 Dependencies

- `http`: HTTP requests
- `file_picker`: File selection
- `image_picker`: Image selection
- `mask_text_input_formatter`: Input masks
- `permission_handler`: Permissions handling
- `shared_preferences`: Local storage
- `provider`: State management

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@seu-usuario](https://github.com/seu-usuario)
- LinkedIn: [Your Name](https://linkedin.com/in/seu-nome)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors who helped with this project

## 📞 Support

For support, email support@simplify.com or open an issue on GitHub.

---

Made with ❤️ using Flutter