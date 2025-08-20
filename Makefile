.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make get          - Get Flutter packages"
	@echo "  make generate     - Generate code with build_runner"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make test         - Run tests"
	@echo "  make analyze      - Analyze code"
	@echo "  make format       - Format code"
	@echo "  make run-dev      - Run app in development mode"
	@echo "  make run-prod     - Run app in production mode"
	@echo "  make build-apk    - Build APK for production"
	@echo "  make build-ios    - Build iOS app for production"

.PHONY: get
get:
	flutter pub get

.PHONY: generate
generate:
	flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

.PHONY: clean
clean:
	flutter clean
	flutter pub get

.PHONY: test
test:
	flutter test

.PHONY: analyze
analyze:
	flutter analyze

.PHONY: format
format:
	dart format lib/ test/

.PHONY: run-dev
run-dev:
	flutter run --dart-define=ENVIRONMENT=development --dart-define=BASE_URL=https://dev-api.example.com

.PHONY: run-prod
run-prod:
	flutter run --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com

.PHONY: build-apk
build-apk:
	flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com

.PHONY: build-ios
build-ios:
	flutter build ios --release --dart-define=ENVIRONMENT=production --dart-define=BASE_URL=https://api.example.com

.PHONY: icons
icons:
	flutter pub run flutter_launcher_icons
