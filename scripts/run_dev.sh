#!/bin/bash

echo "Running app in DEVELOPMENT mode..."
flutter run --dart-define=ENVIRONMENT=development --dart-define=BASE_URL=https://dev-api.example.com
