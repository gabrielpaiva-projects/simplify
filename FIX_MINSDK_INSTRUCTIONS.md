# Correção de Configurações Android (NDK, minSdk e Java)

## 🔴 Problemas Identificados
1. Firebase Auth requer minSdkVersion 23 (estava 21)
2. Plugins requerem NDK versão 27.0.12077973
3. Java 8 está obsoleto, precisa atualizar para Java 11

## ✅ Solução Completa

### Passo 1: Abra o arquivo `/Users/gabriel/Desktop/simplify/android/app/build.gradle`

### Passo 2: Atualize as configurações do Android

Localize o bloco `android {` e faça as seguintes alterações:

```gradle
android {
    namespace = "com.example.simplify"  // ou seu namespace
    compileSdk = flutter.compileSdkVersion
    
    // ADICIONE/ATUALIZE: Versão específica do NDK
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        // ATUALIZE: De VERSION_1_8 para VERSION_11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    kotlinOptions {
        // ATUALIZE: De "1.8" para "11"
        jvmTarget = "11"
    }
    
    defaultConfig {
        applicationId = "com.example.simplify"
        
        // ATUALIZE: De 21 para 23
        minSdkVersion 23
        
        targetSdkVersion = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
        multiDexEnabled true
    }
}
```

### Passo 3: (Opcional) Remova arquivos duplicados

Se você tiver tanto `build.gradle` quanto `build.gradle.kts`, delete o arquivo `build.gradle.kts` para evitar conflitos:

```bash
rm /Users/gabriel/Desktop/simplify/android/app/build.gradle.kts
```

## 📱 Impacto da Mudança

- **Antes**: Suportava Android 5.0 (API 21) e superior
- **Depois**: Suportará Android 6.0 (API 23) e superior
- **Dispositivos afetados**: Apenas dispositivos muito antigos (2014-2015) com Android 5.0/5.1

## 🔄 Após as Mudanças

1. Limpe completamente o projeto:
```bash
cd /Users/gabriel/Desktop/simplify
flutter clean
rm -rf .dart_tool
rm -rf build
```

2. Reconstrua o projeto:
```bash
flutter pub get
flutter run
```

3. Se ainda houver problemas com depfile inválido:
```bash
rm -rf .dart_tool/flutter_build/
flutter clean
flutter pub get
```

## 📊 Estatísticas de Mercado (2024)
- Android 6.0+ representa **97%+** dos dispositivos Android ativos
- Android 5.x representa menos de **3%** do mercado
- Decisão segura para apps modernos

## 📋 Resumo das Mudanças

| Configuração | Antes | Depois | Motivo |
|-------------|--------|---------|---------|
| minSdkVersion | 21 | **23** | Firebase Auth requer |
| ndkVersion | 26.3.11579264 | **27.0.12077973** | Plugins requerem |
| Java Version | 1.8 | **11** | Java 8 está obsoleto |
| jvmTarget | "1.8" | **"11"** | Compatibilidade Kotlin |

## ⚠️ Notas Importantes

1. **NDK Version**: Todos os plugins Firebase e outros requerem NDK 27.0.12077973
2. **Java 11**: Resolve os warnings sobre Java 8 obsoleto
3. **Build duplicado**: Se existir `build.gradle.kts`, delete-o para evitar conflitos
4. **Cache**: Limpar `.dart_tool` resolve problemas de depfile inválido

## ✅ Benefícios
- Compatibilidade total com Firebase mais recente
- Sem warnings de versões obsoletas
- Build mais rápido e estável
- Suporte a recursos modernos do Android