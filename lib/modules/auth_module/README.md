# Módulo de Autenticação (Auth Module)

## Visão Geral

Este módulo contém toda a funcionalidade relacionada à autenticação, login e cadastro de usuários no aplicativo Simplify. Foi projetado para ser independente e reutilizável, seguindo os princípios de arquitetura modular.

## Estrutura do Módulo

```
auth_module/
├── auth_module.dart              # Arquivo principal com exports
├── presentation/                 # Camada de apresentação
│   ├── screens/                  # Telas do módulo
│   │   ├── login_screen.dart
│   │   ├── client_registration_screen.dart
│   │   ├── professional_registration_screen.dart
│   │   ├── modern_client_registration.dart
│   │   ├── modern_professional_registration.dart
│   │   └── professional_analysis_screen.dart
│   └── widgets/                  # Widgets reutilizáveis
│       ├── auth_widgets.dart     # Export de todos os widgets
│       ├── modern_profile_selection_sheet.dart
│       ├── profile_selection_bottom_sheet.dart
│       └── terms_and_conditions_step.dart
├── data/                          # Camada de dados
│   ├── models/                   # Modelos de dados
│   │   ├── user_model.dart
│   │   ├── client_model.dart
│   │   ├── professional_model.dart
│   │   └── address_model.dart
│   └── services/                 # Serviços e APIs
│       ├── auth_service.dart     # Serviço de autenticação
│       ├── registration_service.dart # Serviço de cadastro
│       └── cep_service.dart      # Serviço de busca de CEP
├── domain/                        # Camada de domínio (preparado para expansão)
│   ├── entities/                 # Entidades de negócio
│   ├── repositories/             # Interfaces de repositórios
│   └── usecases/                 # Casos de uso
└── routes/                        # Rotas do módulo
    └── auth_routes.dart           # Definição de rotas

```

## Como Usar

### 1. Importação do Módulo

Para usar o módulo de autenticação, importe o arquivo principal:

```dart
import 'package:simplify/modules/auth_module/auth_module.dart';
```

### 2. Configuração de Rotas

O módulo fornece suas próprias rotas através da classe `AuthModuleRoutes`:

```dart
// No arquivo de rotas principal (app_routes.dart)
if (settings.name?.startsWith('/auth') ?? false) {
  final authRoute = AuthModuleRoutes.generateRoute(settings);
  if (authRoute != null) {
    return authRoute;
  }
}
```

### 3. Navegação

Use os métodos de navegação fornecidos:

```dart
// Navegar para login
AuthModuleRoutes.navigateToLogin(context);

// Navegar para cadastro de cliente
AuthModuleRoutes.navigateToClientRegistration(context);

// Navegar para cadastro de profissional
AuthModuleRoutes.navigateToProfessionalRegistration(context);
```

### 4. Serviços

#### AuthService
Gerencia login, logout e sessão:

```dart
final authService = AuthService();

// Login
await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Verificar autenticação
if (authService.isAuthenticated) {
  // Usuário está logado
}

// Logout
await authService.logout();
```

#### RegistrationService
Gerencia cadastro de novos usuários:

```dart
final registrationService = RegistrationService();

// Cadastrar cliente
final client = await registrationService.registerClient(
  name: 'João Silva',
  email: 'joao@example.com',
  password: 'senha123',
  // ... outros campos
);

// Cadastrar profissional
final professional = await registrationService.registerProfessional(
  name: 'Dr. Maria Santos',
  email: 'maria@example.com',
  password: 'senha123',
  profession: 'Médica',
  // ... outros campos
);
```

## Rotas Disponíveis

- `/auth/login` - Tela de login
- `/auth/register/client` - Cadastro de cliente
- `/auth/register/professional` - Cadastro de profissional
- `/auth/register/modern-client` - Cadastro moderno de cliente
- `/auth/register/modern-professional` - Cadastro moderno de profissional
- `/auth/professional-analysis` - Análise de perfil profissional

## Funcionalidades

### ✅ Implementadas

- Login com email e senha
- Cadastro de clientes
- Cadastro de profissionais
- Upload de documentos e certificados
- Busca automática de CEP
- Máscaras de input (CPF, CNPJ, telefone, CEP)
- Validações em tempo real
- Indicador de força de senha
- Seleção de perfil (cliente/profissional)
- Animações e transições suaves

### 🚧 Em Desenvolvimento

- Autenticação com biometria
- Login social (Google, Facebook, Apple)
- Autenticação dois fatores (2FA)
- Recuperação de senha
- Verificação de email
- Persistência local de sessão

## Dependências

O módulo utiliza os seguintes packages:

- `http`: Para requisições HTTP
- `mask_text_input_formatter`: Para máscaras de input
- `image_picker`: Para upload de fotos
- `file_picker`: Para upload de documentos

## Manutenção

Para adicionar novas funcionalidades ao módulo:

1. Adicione novos arquivos nas pastas apropriadas
2. Exporte no arquivo `auth_module.dart` se necessário
3. Atualize as rotas em `auth_routes.dart` se for uma nova tela
4. Documente as mudanças neste README

## Testes

Os testes do módulo estão localizados em `test/modules/auth_module/`.

Para executar os testes:

```bash
flutter test test/modules/auth_module/
```

## Contribuindo

Ao contribuir com este módulo, siga estas diretrizes:

1. Mantenha a separação de responsabilidades entre as camadas
2. Adicione testes para novas funcionalidades
3. Documente métodos públicos
4. Use nomes descritivos para variáveis e funções
5. Siga o padrão de código do projeto

## Contato

Para dúvidas ou sugestões sobre este módulo, entre em contato com a equipe de desenvolvimento.