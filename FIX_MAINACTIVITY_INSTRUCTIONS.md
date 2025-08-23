# Correção do Erro MainActivity ClassNotFoundException

## 🔴 Problema
O app está crashando porque não consegue encontrar a classe `MainActivity` no pacote `com.example.simplify`.

## ✅ Solução Rápida

### Passo 1: Criar o arquivo MainActivity.kt

Crie o arquivo em: `/Users/gabriel/Desktop/simplify/android/app/src/main/kotlin/com/example/simplify/MainActivity.kt`

```kotlin
package com.example.simplify

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    // Flutter Activity
}
```

### Passo 2: Verificar o AndroidManifest.xml

Verifique se o arquivo `/Users/gabriel/Desktop/simplify/android/app/src/main/AndroidManifest.xml` tem:

1. O atributo `package="com.example.simplify"` no elemento `<manifest>`
2. A activity declarada como `android:name=".MainActivity"`

### Passo 3: Limpar e Reconstruir

```bash
cd /Users/gabriel/Desktop/simplify
flutter clean
flutter pub get
flutter run
```

## 🔍 Verificação da Estrutura

A estrutura de pastas deve ser:
```
android/
  app/
    src/
      main/
        kotlin/
          com/
            example/
              simplify/
                MainActivity.kt
        AndroidManifest.xml
```

## ⚠️ Importante

- O pacote no `MainActivity.kt` DEVE corresponder ao `namespace` no `build.gradle`
- O caminho das pastas DEVE corresponder ao pacote (com/example/simplify)
- Se você mudou o `applicationId` no `build.gradle`, ajuste o pacote e o caminho das pastas correspondentemente

## 🚀 Resultado Esperado

Após essas correções, o app deve:
1. Instalar corretamente
2. Abrir sem crashes
3. Mostrar a SplashScreen
4. Verificar autenticação
5. Redirecionar para a tela apropriada