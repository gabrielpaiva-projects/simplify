# Arquitetura do Projeto Simplify

## Visão Geral

Este projeto implementa uma arquitetura escalável baseada em Clean Architecture com adaptações para Flutter. A estrutura foi projetada para ser modular, testável e de fácil manutenção.

## Estrutura de Pastas

```
lib/
├── core/                       # Componentes compartilhados
│   ├── config/                # Configurações da aplicação
│   │   └── app_config.dart   # Configurações de ambiente
│   ├── constants/             # Constantes globais
│   ├── data/                  # Classes base para data layer
│   │   └── base_repository.dart
│   ├── di/                    # Injeção de dependências
│   │   └── injection_container.dart
│   ├── errors/                # Tratamento de erros
│   │   ├── exceptions.dart   # Exceções customizadas
│   │   └── failures.dart     # Falhas para domain layer
│   ├── network/               # Configuração de rede
│   │   ├── dio_client.dart   # Cliente HTTP
│   │   └── network_info.dart # Verificação de conectividade
│   ├── presentation/          # Componentes de UI compartilhados
│   │   ├── base_state.dart   # Estado base para ViewModels
│   │   └── widgets/           # Widgets reutilizáveis
│   ├── routes/                # Navegação
│   ├── theme/                 # Tema da aplicação
│   ├── usecases/              # Base para use cases
│   │   └── usecase.dart
│   └── utils/                 # Utilitários
│       ├── logger_service.dart
│       ├── snackbar_utils.dart
│       └── validators.dart
├── features/                   # Funcionalidades do app
│   ├── auth/                  # Módulo de autenticação
│   │   ├── data/              # Camada de dados
│   │   ├── domain/            # Regras de negócio
│   │   └── presentation/      # UI
│   └── splash/                # Tela inicial
└── main.dart                  # Ponto de entrada
```

## Camadas da Arquitetura

### 1. **Presentation Layer** (Camada de Apresentação)
- **Responsabilidade**: Interface do usuário e gerenciamento de estado
- **Componentes**:
  - Screens (Telas)
  - Widgets
  - ViewModels/Providers (Gerenciamento de Estado)
- **Padrão**: MVVM com Provider

### 2. **Domain Layer** (Camada de Domínio)
- **Responsabilidade**: Regras de negócio
- **Componentes**:
  - Entities (Entidades)
  - Use Cases (Casos de Uso)
  - Repository Interfaces
- **Características**: Independente de frameworks e bibliotecas externas

### 3. **Data Layer** (Camada de Dados)
- **Responsabilidade**: Acesso e manipulação de dados
- **Componentes**:
  - Repository Implementations
  - Data Sources (Remote/Local)
  - Models (DTOs)
  - Services
- **Padrão**: Repository Pattern

## Tecnologias e Bibliotecas

### Gerenciamento de Estado
- **Provider**: Solução oficial recomendada pelo Flutter
- **BaseState**: Classe abstrata para padronizar estados

### Injeção de Dependências
- **GetIt**: Service locator simples e eficiente
- **Configuração**: Centralizada em `injection_container.dart`

### Rede e API
- **Dio**: Cliente HTTP avançado com interceptors
- **Connectivity Plus**: Verificação de conectividade
- **Tratamento de Erros**: Centralizado com exceções customizadas

### Armazenamento Local
- **Shared Preferences**: Para dados simples e configurações

### Programação Funcional
- **Dartz**: Either para tratamento de erros funcional
- **Equatable**: Comparação de objetos

### Utilitários
- **Logger**: Sistema de logs configurável
- **Validators**: Validações centralizadas
- **JSON Serializable**: Serialização automática (preparado)

## Padrões Implementados

### 1. Repository Pattern
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginParams params);
  Future<Either<Failure, void>> logout();
}
```

### 2. Use Case Pattern
```dart
class LoginUseCase extends UseCase<User, LoginParams> {
  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    // Implementação
  }
}
```

### 3. Provider Pattern (MVVM)
```dart
class AuthViewModel extends BaseState {
  void login() {
    setLoading();
    // Lógica de login
    setSuccess();
  }
}
```

## Configuração de Ambientes

O projeto suporta múltiplos ambientes:

```dart
enum Environment { development, staging, production }
```

Configuração no `main.dart`:
```dart
AppConfig.setEnvironment(Environment.development);
```

## Tratamento de Erros

### Hierarquia de Failures
- `Failure` (abstrata)
  - `ServerFailure`
  - `CacheFailure`
  - `NetworkFailure`
  - `ValidationFailure`
  - `UnknownFailure`

### Hierarquia de Exceptions
- `AppException` (base)
  - `ServerException`
  - `CacheException`
  - `NetworkException`
  - `ValidationException`

## Como Adicionar uma Nova Feature

1. **Criar estrutura de pastas**:
```
features/
└── nova_feature/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── providers/
        ├── screens/
        └── widgets/
```

2. **Implementar camadas de baixo para cima**:
   - Domain (entities, repository interfaces, use cases)
   - Data (models, data sources, repository implementations)
   - Presentation (providers, screens, widgets)

3. **Registrar dependências** em `injection_container.dart`

4. **Adicionar rotas** se necessário

## Benefícios da Arquitetura

1. **Escalabilidade**: Fácil adicionar novas features
2. **Testabilidade**: Cada camada pode ser testada isoladamente
3. **Manutenibilidade**: Código organizado e padronizado
4. **Reusabilidade**: Componentes compartilhados no core
5. **Separação de Responsabilidades**: Cada camada tem função específica
6. **Independência**: Domain layer não depende de frameworks

## Próximos Passos

1. Migrar features existentes para nova arquitetura
2. Implementar testes unitários e de integração
3. Adicionar CI/CD
4. Implementar cache local com banco de dados
5. Adicionar internacionalização (i18n)