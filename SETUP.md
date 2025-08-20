# Setup e Instalação - Simplify

## 🔧 Correção de Erros de Compilação

Os erros que você está vendo são normais e esperados antes de executar a geração de código. Siga estes passos:

### 1. Instale as Dependências

```bash
flutter pub get
```

### 2. Gere o Código Necessário

O projeto usa geração de código para:
- Modelos Freezed
- Serialização JSON
- Injeção de Dependências
- Providers Riverpod
- Cliente Retrofit

Execute:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Se os Erros Persistirem

Se ainda houver erros após a geração de código:

```bash
# Limpe o projeto
flutter clean

# Reinstale as dependências
flutter pub get

# Force a regeneração
flutter pub run build_runner build --delete-conflicting-outputs --verbose
```

## 📝 Arquivos que Serão Gerados

Após executar o build_runner, os seguintes arquivos serão criados:

- `lib/core/di/injection_container.config.dart`
- `lib/features/auth/data/models/user_model.freezed.dart`
- `lib/features/auth/data/models/user_model.g.dart`
- `lib/features/auth/data/models/auth_response_model.freezed.dart`
- `lib/features/auth/data/models/auth_response_model.g.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.g.dart`
- `lib/features/auth/presentation/providers/auth_provider.g.dart`
- `lib/features/auth/presentation/providers/auth_state.freezed.dart`

## 🚀 Script de Setup Automático

Use o script de setup para configurar tudo automaticamente:

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## ⚠️ Problemas Comuns

### Erro: "Flutter command not found"
- Certifique-se de que o Flutter está instalado e no PATH
- Verifique com: `flutter doctor`

### Erro: "Build runner conflicts"
- Use a flag `--delete-conflicting-outputs`
- Ou delete manualmente os arquivos `.g.dart` e `.freezed.dart`

### Erro: "Cannot find generator"
- Verifique se todas as dependências dev estão instaladas
- Execute: `flutter pub get` novamente

## 🔄 Desenvolvimento Contínuo

Durante o desenvolvimento, você pode usar o modo watch para regeneração automática:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Isso manterá o build_runner rodando e regenerará o código automaticamente quando você fizer mudanças.

## ✅ Verificação

Após o setup, verifique se tudo está funcionando:

```bash
# Analise o código
flutter analyze

# Execute os testes
flutter test

# Execute o app
flutter run
```

## 📚 Próximos Passos

1. Configure seu arquivo `.env` com as variáveis necessárias
2. Ajuste as URLs da API no arquivo de constantes
3. Implemente os endpoints reais no `AuthRemoteDataSource`
4. Adicione mais testes unitários
5. Configure CI/CD se necessário

## 💡 Dicas

- Use o Makefile para comandos comuns: `make help`
- Mantenha o build_runner watch rodando durante o desenvolvimento
- Sempre gere código após modificar modelos Freezed ou adicionar anotações
- Use os scripts na pasta `scripts/` para diferentes ambientes
