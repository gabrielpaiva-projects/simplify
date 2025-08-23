# 🎨 Atualização do Ícone do App

## ✅ Configuração Já Aplicada

O arquivo `pubspec.yaml` foi atualizado para usar o `app_logo.png` como ícone do aplicativo.

## 📱 Para Gerar os Ícones

Execute os seguintes comandos no terminal:

### 1. Instale as dependências
```bash
cd /Users/gabriel/Desktop/simplify
flutter pub get
```

### 2. Gere os ícones
```bash
flutter pub run flutter_launcher_icons
```

### 3. Limpe e reconstrua o projeto
```bash
flutter clean
flutter pub get
```

### 4. Para Android
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

### 5. Para iOS (se estiver no macOS)
```bash
cd ios
pod install
cd ..
flutter build ios
```

## 🔍 O que foi configurado

- **Android**: Ícone adaptativo com fundo branco
- **iOS**: Ícone com fundo removido (remove_alpha_ios)
- **Imagem**: `assets/app_logo.png`
- **Min SDK Android**: 23 (compatível com as configurações atuais)

## 📂 Onde os ícones são gerados

### Android
- `/android/app/src/main/res/mipmap-hdpi/`
- `/android/app/src/main/res/mipmap-mdpi/`
- `/android/app/src/main/res/mipmap-xhdpi/`
- `/android/app/src/main/res/mipmap-xxhdpi/`
- `/android/app/src/main/res/mipmap-xxxhdpi/`

### iOS
- `/ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## ⚠️ Importante

1. **Desinstale o app antigo** do dispositivo/emulador antes de instalar com o novo ícone
2. **Reinicie o dispositivo** se o ícone não atualizar imediatamente
3. **Para iOS**: Pode ser necessário limpar o cache do Xcode

## 🚀 Teste Final

Após gerar os ícones e reconstruir:

```bash
# Para testar no Android
flutter run

# Para testar no iOS
flutter run -d ios
```

## 🎯 Resultado Esperado

- O ícone do Flutter será substituído pelo `app_logo.png`
- O ícone aparecerá na tela inicial do dispositivo
- O ícone aparecerá na lista de apps recentes
- O ícone aparecerá na Play Store/App Store quando publicado