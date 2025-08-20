#!/bin/bash

echo "Running app in PRODUCTION mode..."
flutter run --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com
