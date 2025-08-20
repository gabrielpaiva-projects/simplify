# 🚀 Configuração e Execução do Projeto Simplify

## 📋 Pré-requisitos

- Flutter SDK (versão 3.0 ou superior)
- Dart SDK (versão 3.0 ou superior)
- Android Studio / VS Code com extensões Flutter
- Dispositivo físico ou emulador configurado

## 🔧 Instalação

### 1. Clone o repositório
```bash
git clone [seu-repositorio]
cd simplify
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Execute o projeto
```bash
flutter run
```

## 🧪 Executar Testes
```bash
flutter test
```

## 📱 Build para Produção

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔑 Credenciais de Teste (Mock)

Para testar o login com dados mockados:

- **Email:** `user@example.com`
- **Senha:** `password123`

Ou:

- **Email:** `admin@example.com`
- **Senha:** `admin123`

## 🏗️ Estrutura do Projeto

```
lib/
├── core/               # Recursos compartilhados
├── data/               # Camada de dados
├── domain/             # Regras de negócio
└── presentation/       # UI e gerenciamento de estado
```

## 🔄 Fluxo da Aplicação

1. **Splash Screen** → Verifica autenticação
2. **Login Screen** → Autenticação do usuário
3. **Home Screen** → Tela principal (em desenvolvimento)

## 🛠️ Configurações Importantes

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto (opcional):

```env
API_BASE_URL=https://api.simplify.com
```

### Firebase (Futura Integração)

Quando for integrar com Firebase:

1. Configure o projeto no Firebase Console
2. Baixe os arquivos de configuração:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
3. Substitua `MockAuthRemoteDataSource` pela implementação real

## 🐛 Solução de Problemas

### Erro: "Flutter command not found"
```bash
export PATH="$PATH:[caminho-do-flutter]/bin"
```

### Erro: "pub get failed"
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Erro de build no Android
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

### Erro de build no iOS
```bash
cd ios
pod install
cd ..
flutter build ios
```

## 📝 Notas de Desenvolvimento

- O projeto usa **dados mockados** por enquanto
- A autenticação real será implementada com **Firebase**
- Todas as chamadas de API estão preparadas para substituição
- A arquitetura está pronta para escalar

## 🤝 Contribuindo

1. Crie uma branch para sua feature
2. Faça commit das mudanças
3. Push para a branch
4. Abra um Pull Request

## 📚 Documentação Adicional

- [Arquitetura do Projeto](ARCHITECTURE.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📞 Suporte

Em caso de dúvidas ou problemas, abra uma issue no repositório.