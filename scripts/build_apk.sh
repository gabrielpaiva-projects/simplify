#!/bin/bash

echo "Building APK for PRODUCTION..."
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com
