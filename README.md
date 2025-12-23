# Lighten Up

A HIPAA-compliant, real-time intra-office communication system for healthcare teams. Provides a virtual light system for coordinating patient flow and workflow with filterable/sortable views and real-time updates.

**Tech Stack:** Flutter/Dart with ConnectRPC, Protocol Buffers, and SQLite

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Setup](#development-setup)
  - [macOS](#macos-setup)
  - [Linux](#linux-setup)
- [Project Setup](#project-setup)
- [Running the Application](#running-the-application)
- [Development Workflow](#development-workflow)
- [Project Structure](#project-structure)
- [Documentation](#documentation)

---

## Prerequisites

### Required Tools

1. **Flutter SDK** (3.0.0 or higher)
2. **Dart SDK** (included with Flutter)
3. **Buf CLI** (for Protocol Buffer code generation)
4. **Git**

### Platform-Specific Requirements

#### macOS
- Xcode 14+ (for iOS development)
- CocoaPods (for iOS dependencies)
- Homebrew (recommended for package management)

#### Linux
- GCC and Make (for native dependencies)
- pkg-config
- libc6-dev
- libsqlite3-dev

---

## Development Setup

### macOS Setup

#### 1. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Install Flutter
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell configuration
source ~/.zshrc  # or source ~/.bash_profile

# Verify installation
flutter doctor
```

Or use Homebrew:
```bash
brew install --cask flutter
```

#### 3. Install Buf CLI
```bash
brew install bufbuild/buf/buf

# Verify installation
buf --version
```

#### 4. Install Xcode (for iOS development)
```bash
# Install from App Store or:
xcode-select --install

# Accept license
sudo xcodebuild -license accept

# Install CocoaPods
sudo gem install cocoapods
```

#### 5. Setup Android Studio (for Android development)
1. Download from https://developer.android.com/studio
2. Install Android SDK
3. Configure in Flutter:
```bash
flutter config --android-sdk /path/to/android/sdk
flutter doctor --android-licenses
```

#### 6. Verify Setup
```bash
flutter doctor -v
```

All checkmarks should be green. Address any issues reported.

---

### Linux Setup

#### 1. Install Flutter

**Ubuntu/Debian:**
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install additional dependencies for SQLite and native code
sudo apt-get install -y libc6-dev libsqlite3-dev pkg-config

# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell configuration
source ~/.bashrc

# Verify installation
flutter doctor
```

**Fedora/RHEL:**
```bash
# Install dependencies
sudo dnf install -y curl git unzip xz zip mesa-libGLU

# Install additional dependencies
sudo dnf install -y glibc-devel sqlite-devel pkgconfig

# Follow same Flutter installation as Ubuntu above
```

**Arch Linux:**
```bash
# Install dependencies
sudo pacman -S curl git unzip xz zip mesa

# Install additional dependencies
sudo pacman -S base-devel sqlite

# Follow same Flutter installation as Ubuntu above
```

#### 2. Install Buf CLI

**Using Homebrew (Linuxbrew):**
```bash
# Install Homebrew for Linux
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (follow instructions after install)

# Install Buf
brew install bufbuild/buf/buf
```

**Using Binary Download:**
```bash
# Download latest release
BUF_VERSION="1.28.1"  # Check https://github.com/bufbuild/buf/releases for latest
curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
  -o buf

# Make executable and move to PATH
chmod +x buf
sudo mv buf /usr/local/bin/

# Verify installation
buf --version
```

#### 3. Setup Android Studio (for Android development)

**Download and Install:**
```bash
# Download from https://developer.android.com/studio
# Or use snap:
sudo snap install android-studio --classic

# Configure Android SDK path
flutter config --android-sdk ~/Android/Sdk

# Accept licenses
flutter doctor --android-licenses
```

#### 4. Install Chrome/Chromium (for web development)
```bash
# Ubuntu/Debian
sudo apt-get install -y chromium-browser

# Fedora
sudo dnf install -y chromium

# Arch
sudo pacman -S chromium
```

#### 5. Verify Setup
```bash
flutter doctor -v
```

All checkmarks should be green. Address any issues reported.

---

## Project Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd lighten-up
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Generate Protocol Buffer Code
```bash
cd proto
buf generate
cd ..
```

This will generate Dart code from `.proto` files into `lib/gen/`.

### 4. Verify Code Generation
```bash
# Check that generated files exist
ls -la lib/gen/lighten/v1/

# Should see files like:
# - common.pb.dart
# - models.pb.dart
# - light_service.connect.client.dart
# - state_service.connect.client.dart
```

### 5. Run Code Analysis
```bash
flutter analyze
```

### 6. Run Tests
```bash
flutter test
```

---

## Running the Application

### Run Client (Development Mode)
```bash
# Desktop (macOS)
flutter run -d macos

# Desktop (Linux)
flutter run -d linux

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

### Run Server (Standalone)
```bash
# Run server on default port (8080)
dart run lib/src/server/main.dart

# Run with custom port
dart run lib/src/server/main.dart --port 5000

# Run with mDNS discovery
dart run lib/src/server/main.dart --mdns
```

### Run Client with Server URL
```bash
# Connect to specific server
flutter run --dart-define=SERVER_URL=http://localhost:8080

# Use mDNS discovery (default)
flutter run
```

---

## Development Workflow

### 1. Making Changes to Protocol Buffers

When you modify `.proto` files:

```bash
# 1. Edit proto files
vim proto/lighten/v1/models.proto

# 2. Regenerate code
cd proto
buf generate
cd ..

# 3. Run code analysis
flutter analyze

# 4. Run tests
flutter test
```

### 2. Code Formatting
```bash
# Format all Dart files
dart format .

# Check formatting without changes
dart format --output=none --set-exit-if-changed .
```

### 3. Linting
```bash
# Run analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### 4. Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/light_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### 5. Building
```bash
# Build for macOS
flutter build macos

# Build for Linux
flutter build linux

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for web
flutter build web
```

---

## Project Structure

```
lighten-up/
├── proto/                          # Protocol Buffer definitions
│   ├── buf.yaml                    # Buf configuration
│   ├── buf.gen.yaml                # Code generation config
│   └── lighten/v1/                 # Proto files
│
├── lib/
│   ├── gen/                        # Generated protobuf code (DO NOT EDIT)
│   ├── src/
│   │   ├── models/                 # Domain models & extensions
│   │   ├── storage/                # Storage layer (SQLite, etc.)
│   │   ├── network/                # Network layer (ConnectRPC)
│   │   ├── server/                 # Server implementation
│   │   ├── state/                  # State management
│   │   ├── ui/                     # UI components
│   │   └── utils/                  # Utilities
│   └── main.dart                   # App entry point
│
├── test/                           # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── docs/                           # Documentation
│   ├── ARCHITECTURE_SUMMARY.md
│   ├── PROTOCOL_DESIGN.md
│   ├── TASK_BREAKDOWN.md
│   └── ...
│
├── pubspec.yaml                    # Dependencies
└── README.md                       # This file
```

---

## Documentation

- **[Architecture Summary](docs/ARCHITECTURE_SUMMARY.md)** - High-level architecture overview
- **[Protocol Design](docs/PROTOCOL_DESIGN.md)** - ConnectRPC protocol and service definitions
- **[Task Breakdown](docs/TASK_BREAKDOWN.md)** - Complete task list (46 tasks)
- **[Network Architecture](docs/TASK_0_NETWORKING_ARCHITECTURE.md)** - Network design decisions
- **[BlueNote PRD](docs/BLUENOTE_PRD.md)** - Product requirements (inspiration)
- **[Workflow Details](docs/WORKFLOW_DETAILS.md)** - User workflows and UX

---

## Common Issues & Troubleshooting

### Issue: `buf: command not found`
**Solution:** Ensure Buf CLI is installed and in your PATH. Run `buf --version` to verify.

### Issue: Code generation fails
**Solution:**
```bash
cd proto
buf mod update
buf generate
```

### Issue: Flutter doctor shows issues
**Solution:** Run `flutter doctor -v` and follow the instructions for each issue.

### Issue: SQLite errors on Linux
**Solution:** Install SQLite development headers:
```bash
sudo apt-get install libsqlite3-dev  # Ubuntu/Debian
sudo dnf install sqlite-devel        # Fedora
```

### Issue: Generated code has import errors
**Solution:** Ensure you've run `flutter pub get` after code generation.

### Issue: mDNS discovery not working
**Solution:**
- macOS: Check firewall settings
- Linux: Install Avahi: `sudo apt-get install avahi-daemon`

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `flutter test`
5. Format code: `dart format .`
6. Commit changes: `git commit -am 'Add feature'`
7. Push to branch: `git push origin feature/my-feature`
8. Submit a pull request

---

## License

[License information here]

---

## Support

For questions or issues:
- Create an issue on GitHub
- See documentation in `docs/`
- Review task breakdown for implementation guidance

---

**Stitch UI URL:** https://stitch.withgoogle.com/projects/1681772610196305283
