#!/bin/bash

echo "🚀 Setting up Simplify project..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate code
echo "⚙️ Generating code with build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Run 'make run-dev' to start the app in development mode"
echo "  2. Run 'make test' to run tests"
echo "  3. Check ARCHITECTURE.md for project structure details"
