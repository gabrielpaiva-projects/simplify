# 🏗️ Arquitetura do Projeto Simplify

## 📋 Visão Geral

Este projeto segue os princípios da **Clean Architecture** com **BLoC Pattern** para gerenciamento de estado, uma abordagem amplamente utilizada em aplicações Flutter empresariais de grande escala.

## 🎯 Princípios Fundamentais

- **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
- **Inversão de Dependências**: As camadas internas não conhecem as externas
- **Testabilidade**: Código facilmente testável com injeção de dependências
- **Escalabilidade**: Estrutura preparada para crescimento
- **Manutenibilidade**: Código organizado e de fácil manutenção

## 📁 Estrutura de Pastas

```
lib/
├── core/                       # Recursos compartilhados
│   ├── constants/             # Constantes da aplicação
│   ├── di/                    # Injeção de dependências
│   ├── errors/                # Tratamento de erros
│   ├── extensions/            # Extensões Dart/Flutter
│   ├── network/               # Configuração de rede
│   ├── theme/                 # Temas da aplicação
│   ├── utils/                 # Utilitários gerais
│   └── widgets/               # Widgets compartilhados
│
├── data/                      # Camada de Dados
│   ├── datasources/          # Fontes de dados
│   │   ├── local/           # Cache local
│   │   └── remote/          # APIs remotas
│   ├── models/              # Modelos de dados
│   └── repositories/        # Implementação dos repositórios
│
├── domain/                    # Camada de Domínio (Regras de Negócio)
│   ├── entities/            # Entidades de negócio
│   ├── repositories/        # Contratos dos repositórios
│   └── usecases/           # Casos de uso
│
└── presentation/             # Camada de Apresentação
    ├── blocs/               # BLoCs para gerenciamento de estado
    ├── pages/               # Páginas/Telas
    ├── router/              # Navegação
    └── widgets/             # Widgets específicos das features
```

## 🔄 Fluxo de Dados

```
UI (Pages/Widgets)
    ↓ ↑
BLoC (State Management)
    ↓ ↑
Use Cases (Business Logic)
    ↓ ↑
Repositories (Contracts)
    ↓ ↑
Data Sources (Implementation)
    ↓ ↑
External Services (API/Cache)
```

## 🧩 Camadas da Arquitetura

### 1. **Domain Layer** (Camada de Domínio)
- **Entities**: Objetos de negócio puros
- **Repositories**: Interfaces/contratos
- **Use Cases**: Lógica de negócio específica
- Não depende de nenhuma outra camada
- Contém as regras de negócio mais importantes

### 2. **Data Layer** (Camada de Dados)
- **Models**: Representações de dados com serialização
- **Data Sources**: Implementação de acesso a dados
- **Repository Implementations**: Implementação dos contratos
- Converte entre Models e Entities
- Gerencia cache e chamadas de API

### 3. **Presentation Layer** (Camada de Apresentação)
- **BLoCs**: Gerenciamento de estado
- **Pages**: Telas da aplicação
- **Widgets**: Componentes reutilizáveis
- **Router**: Navegação entre telas
- Responsável pela UI e interação com usuário

### 4. **Core** (Núcleo)
- **DI**: Configuração de injeção de dependências
- **Network**: Interceptors, configuração do Dio
- **Errors**: Exceptions e Failures customizadas
- **Utils**: Formatadores, validadores, constantes
- **Extensions**: Extensões úteis
- **Theme**: Temas e estilos globais

## 🔧 Tecnologias Utilizadas

### Gerenciamento de Estado
- **flutter_bloc**: Implementação do padrão BLoC
- **equatable**: Comparação de objetos

### Injeção de Dependências
- **get_it**: Service Locator
- **injectable**: Geração de código para DI

### Rede e API
- **dio**: Cliente HTTP
- **retrofit**: Type-safe HTTP client
- **connectivity_plus**: Verificação de conectividade

### Armazenamento Local
- **shared_preferences**: Dados simples
- **flutter_secure_storage**: Dados sensíveis
- **hive**: Banco de dados NoSQL

### Navegação
- **go_router**: Roteamento declarativo

### Utilitários
- **dartz**: Programação funcional (Either, Option)
- **freezed**: Geração de código imutável
- **json_serializable**: Serialização JSON

## 🚀 Como Adicionar uma Nova Feature

### 1. Domain Layer
```dart
// 1. Criar Entity
class Product extends Equatable {
  final String id;
  final String name;
  // ...
}

// 2. Criar Repository Interface
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}

// 3. Criar Use Case
class GetProductsUseCase extends UseCase<List<Product>, NoParams> {
  final ProductRepository repository;
  // ...
}
```

### 2. Data Layer
```dart
// 1. Criar Model
@freezed
class ProductModel with _$ProductModel {
  factory ProductModel.fromJson(Map<String, dynamic> json) = _ProductModel;
}

// 2. Criar Data Source
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

// 3. Implementar Repository
class ProductRepositoryImpl implements ProductRepository {
  // ...
}
```

### 3. Presentation Layer
```dart
// 1. Criar BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // ...
}

// 2. Criar Page
class ProductPage extends StatelessWidget {
  // ...
}

// 3. Criar Widgets
class ProductCard extends StatelessWidget {
  // ...
}
```

## 🧪 Testes

```
test/
├── unit/
│   ├── domain/
│   ├── data/
│   └── core/
├── widget/
│   └── presentation/
└── integration/
```

## 📝 Convenções de Código

- **Naming**: snake_case para arquivos, PascalCase para classes
- **Imports**: Relativos dentro do mesmo package
- **Formatação**: Usar `flutter format`
- **Análise**: Seguir regras do `flutter analyze`

## 🔐 Segurança

- Tokens sensíveis em `FlutterSecureStorage`
- Validação de inputs em todas as camadas
- Sanitização de dados antes de exibir
- HTTPS obrigatório para produção

## 📱 Responsividade

- Uso de `MediaQuery` para dimensões
- Breakpoints definidos em extensões
- Widgets adaptativos por plataforma
- Suporte a orientação portrait/landscape

## 🎨 Temas

- Suporte a Light/Dark mode
- Cores centralizadas em `AppColors`
- Tipografia consistente
- Componentes temáticos reutilizáveis

## 🔄 Estado da Aplicação

```
Initial → Loading → Success/Error
         ↓
      Refreshing
```

## 📊 Padrões de Código

### Repository Pattern
```dart
Future<Either<Failure, Success>> operation() async {
  try {
    // Verificar conectividade
    // Tentar operação remota
    // Atualizar cache
    return Right(success);
  } catch (e) {
    return Left(failure);
  }
}
```

### BLoC Pattern
```dart
on<Event>((event, emit) async {
  emit(LoadingState());
  final result = await useCase(params);
  result.fold(
    (failure) => emit(ErrorState(failure)),
    (success) => emit(SuccessState(success)),
  );
});
```

## 🚦 Próximos Passos

1. ✅ Configurar Firebase
2. ⬜ Implementar autenticação real
3. ⬜ Adicionar testes unitários
4. ⬜ Implementar CI/CD
5. ⬜ Adicionar analytics
6. ⬜ Implementar notificações push

## 📚 Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev)
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)