# Simplify App

Um aplicativo Flutter moderno com arquitetura limpa e design elegante.

## 🎨 Design System

O app utiliza um sistema de cores consistente:
- **Preto Material**: `#212121` - Cor principal e elementos principais
- **Preto Escuro**: `#0D0D0D` - Fundos e gradientes
- **Branco**: `#FFFFFF` - Fundos de formulários e contrastes
- **Cinza Claro**: `#F5F5F5` - Campos de texto em tom mais claro

## 🏗️ Arquitetura

O projeto segue os princípios de Clean Architecture e SOLID:

```
lib/
├── core/                    # Funcionalidades centrais
│   ├── constants/          # Constantes do app
│   ├── theme/              # Tema e estilos
│   └── routes/             # Sistema de rotas
├── features/               # Funcionalidades do app
│   ├── auth/               # Autenticação
│   │   └── presentation/   # Camada de apresentação
│   │       ├── screens/    # Telas
│   │       └── widgets/    # Widgets reutilizáveis
│   └── splash/             # Tela de splash
│       └── presentation/   # Camada de apresentação
│           └── screens/    # Telas
└── main.dart               # Ponto de entrada
```

## 🚀 Funcionalidades

### Splash Screen
- Animação de entrada elegante
- Logo do app com efeitos visuais
- Transição automática para tela de login após 3 segundos

### Tela de Login (Design Atualizado)
- **Tema Preto**: Header com gradiente preto elegante
- **Campos de Texto**: CPF e senha com fundo cinza claro
- **Validação CPF**: Máscara automática e validação real
- **Botão Login**: Gradiente preto com sombra elegante
- **Design Minimalista**: Foco na usabilidade e estética

## 🛠️ Como Executar

1. **Clone o repositório**
   ```bash
   git clone <url-do-repositorio>
   cd simplify
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o app**
   ```bash
   flutter run
   ```

## 📱 Plataformas Suportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🔧 Dependências

- Flutter SDK: ^3.8.1
- Cupertino Icons: ^1.0.8
- Flutter Lints: ^5.0.0

## 🎯 Próximos Passos

- [ ] Implementar autenticação real
- [ ] Adicionar tela de cadastro
- [ ] Implementar navegação para tela principal
- [ ] Adicionar testes unitários
- [ ] Configurar CI/CD

## 📄 Licença

Este projeto é privado e não deve ser publicado publicamente.
