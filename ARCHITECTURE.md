# Arquitetura do Projeto Simplify

## Visão Geral

Este projeto segue os princípios da **Clean Architecture** com uma estrutura modular e escalável, utilizando as melhores práticas de desenvolvimento Flutter.

## Estrutura de Pastas

```
lib/
├── core/                      # Funcionalidades compartilhadas
│   ├── constants/            # Constantes da aplicação
│   ├── di/                   # Injeção de dependências
│   ├── errors/               # Tratamento de erros
│   ├── network/              # Configuração de rede
│   ├── routes/               # Navegação
│   ├── theme/                # Temas da aplicação
│   ├── usecases/             # Casos de uso base
│   ├── utils/                # Utilitários
│   └── widgets/              # Widgets reutilizáveis
│
├── features/                  # Módulos da aplicação
│   └── [feature_name]/       # Ex: auth, home, profile
│       ├── domain/           # Camada de domínio (regras de negócio)
│       │   ├── entities/     # Entidades de negócio
│       │   ├── repositories/ # Interfaces de repositório
│       │   └── usecases/     # Casos de uso
│       │
│       ├── data/             # Camada de dados
│       │   ├── datasources/  # Fontes de dados (API, Local)
│       │   ├── models/       # Modelos de dados
│       │   └── repositories/ # Implementação dos repositórios
│       │
│       └── presentation/     # Camada de apresentação
│           ├── providers/    # Gerenciamento de estado (Riverpod)
│           ├── screens/      # Telas
│           └── widgets/      # Widgets específicos do módulo
│
└── main.dart                  # Ponto de entrada da aplicação
```

## Tecnologias e Bibliotecas

### Gerenciamento de Estado
- **Flutter Riverpod**: Solução reativa e type-safe para gerenciamento de estado

### Injeção de Dependências
- **GetIt**: Service locator para injeção de dependências
- **Injectable**: Geração de código para configuração do GetIt

### Rede e API
- **Dio**: Cliente HTTP poderoso e flexível
- **Retrofit**: Type-safe REST client
- **Pretty Dio Logger**: Logging de requisições HTTP

### Armazenamento Local
- **Shared Preferences**: Armazenamento de preferências simples
- **Flutter Secure Storage**: Armazenamento seguro de dados sensíveis

### Geração de Código
- **Freezed**: Unions/pattern matching e data classes imutáveis
- **JSON Serializable**: Serialização JSON automática
- **Build Runner**: Ferramenta de geração de código

### Utilitários
- **Dartz**: Programação funcional (Either, Option)
- **Equatable**: Comparação de objetos simplificada
- **Flutter Dotenv**: Variáveis de ambiente

## Princípios Arquiteturais

### 1. Clean Architecture
- **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
- **Independência de Frameworks**: A lógica de negócio não depende de frameworks externos
- **Testabilidade**: Facilita a criação de testes unitários e de integração
- **Independência de UI**: A lógica de negócio não depende da interface

### 2. SOLID Principles
- **S**ingle Responsibility: Cada classe tem uma única responsabilidade
- **O**pen/Closed: Aberto para extensão, fechado para modificação
- **L**iskov Substitution: Subtipos devem ser substituíveis por seus tipos base
- **I**nterface Segregation: Interfaces específicas são melhores que uma geral
- **D**ependency Inversion: Dependa de abstrações, não de implementações

### 3. Camadas da Arquitetura

#### Domain Layer (Camada de Domínio)
- Contém a lógica de negócio pura
- Define entidades, repositórios (interfaces) e casos de uso
- Não depende de nenhuma outra camada
- Exemplo: `User` entity, `AuthRepository` interface, `LoginUseCase`

#### Data Layer (Camada de Dados)
- Implementa os repositórios definidos no domínio
- Gerencia fontes de dados (API, banco de dados, cache)
- Converte entre modelos de dados e entidades
- Exemplo: `AuthRepositoryImpl`, `UserModel`, `AuthRemoteDataSource`

#### Presentation Layer (Camada de Apresentação)
- Gerencia a UI e o estado da aplicação
- Utiliza Riverpod para gerenciamento de estado
- Comunica-se com o domínio através dos casos de uso
- Exemplo: `LoginScreen`, `AuthProvider`, `AuthState`

## Fluxo de Dados

```
UI (Screen/Widget)
    ↓ ↑
Provider (State Management)
    ↓ ↑
Use Case (Business Logic)
    ↓ ↑
Repository (Interface)
    ↓ ↑
Repository Implementation
    ↓ ↑
Data Source (API/Local)
```

## Tratamento de Erros

O projeto utiliza o padrão `Either` do pacote `dartz` para tratamento de erros:

- **Left**: Representa uma falha (`Failure`)
- **Right**: Representa um sucesso com o valor esperado

### Tipos de Failures
- `ServerFailure`: Erros do servidor
- `NetworkFailure`: Problemas de conectividade
- `CacheFailure`: Erros de cache local
- `ValidationFailure`: Erros de validação
- `UnauthorizedFailure`: Acesso não autorizado
- `UnknownFailure`: Erros desconhecidos

## Configuração de Ambiente

O projeto utiliza variáveis de ambiente através do arquivo `.env`:

```env
BASE_URL=https://api.example.com
API_VERSION=/v1
ENVIRONMENT=development
```

## Comandos Úteis

### Geração de Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Executar Testes
```bash
flutter test
```

### Análise de Código
```bash
flutter analyze
```

## Boas Práticas

1. **Sempre use casos de uso** para lógica de negócio
2. **Mantenha as entidades puras** sem dependências externas
3. **Use modelos freezed** para imutabilidade e geração de código
4. **Implemente testes** para casos de uso e repositórios
5. **Use injeção de dependências** para melhor testabilidade
6. **Siga as convenções de nomenclatura** do Dart/Flutter
7. **Documente código complexo** com comentários claros
8. **Use providers específicos** para cada feature
9. **Mantenha widgets pequenos e focados** em uma única responsabilidade
10. **Reutilize widgets comuns** através da pasta `core/widgets`

## Adicionando Novas Features

Para adicionar uma nova feature, siga estes passos:

1. Crie a estrutura de pastas:
   ```
   lib/features/[feature_name]/
   ├── domain/
   ├── data/
   └── presentation/
   ```

2. Defina as entidades no domínio
3. Crie as interfaces de repositório
4. Implemente os casos de uso
5. Crie os modelos de dados
6. Implemente os repositórios
7. Configure os data sources
8. Crie os providers para gerenciamento de estado
9. Desenvolva as telas e widgets
10. Adicione testes unitários

## Exemplo de Implementação

Veja o módulo de autenticação (`lib/features/auth/`) como exemplo de implementação completa seguindo esta arquitetura.
