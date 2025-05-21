#!/bin/bash

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found. Are you in a Flutter project directory?"
    exit 1
fi

# Check if FVM is installed
if ! command -v fvm &> /dev/null; then
    echo "Error: FVM is not installed. Please install it first using:"
    echo "brew tap leoafarias/fvm"
    echo "brew install fvm"
    exit 1
fi

# Initialize FVM in the project
echo "Initializing FVM in the project..."
fvm config

# Create .fvm directory if it doesn't exist
mkdir -p .fvm

# Add .fvm/flutter_sdk to .gitignore
if [ -f .gitignore ]; then
    if ! grep -q "^.fvm/flutter_sdk" .gitignore; then
        echo "" >> .gitignore
        echo "# FVM" >> .gitignore
        echo ".fvm/flutter_sdk" >> .gitignore
    fi
else
    echo ".fvm/flutter_sdk" > .gitignore
fi

# Install Flutter version
read -p "Enter Flutter version to use (e.g., stable, beta, 3.19.0): " version
fvm install $version

# Set the version for the project
fvm use $version

# Create VS Code settings if needed
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
    "dart.flutterSdkPath": ".fvm/flutter_sdk",
    "search.exclude": {
        "**/.fvm": true
    },
    "files.watcherExclude": {
        "**/.fvm": true
    }
}
EOF
cat > .vscode/launch.json << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (FVM)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "program": "lib/main.dart",
      "toolArgs": [],
      "cwd": "${workspaceFolder}",
      "env": {
        "FLUTTER_SDK": "${workspaceFolder}/.fvm/flutter_sdk"
      }
    }
  ]
}
EOF


echo "
FVM setup complete! Your project is now configured to use Flutter $version

Next steps:
1. Run 'fvm flutter pub get' to install dependencies
2. Use 'fvm flutter' instead of 'flutter' for all commands
3. If using CI/CD, update your scripts to use FVM

Common commands:
- Build: fvm flutter build
- Run: fvm flutter run
- Test: fvm flutter test
- Clean: fvm flutter clean
"