#!/bin/bash

echo "🔧 Corrigindo dependências do iOS..."

# Navegar para o diretório iOS
cd ios

echo "📦 Limpando cache do CocoaPods..."
rm -rf ~/Library/Caches/CocoaPods
rm -rf Pods
rm -rf Podfile.lock

echo "🔄 Atualizando repositório CocoaPods..."
pod repo update

echo "📥 Limpando cache do Flutter..."
cd ..
flutter clean

echo "📦 Obtendo dependências do Flutter..."
flutter pub get

echo "🍎 Instalando pods do iOS..."
cd ios
pod install --repo-update

echo "✅ Pronto! Tente executar o app novamente."