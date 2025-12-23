# Flutter Project Development Rules

These rules apply to ALL agents working on Flutter projects.

## Project Context
- **Framework**: Flutter 3.32.5
- **Language**: Dart
- **Project**: Lighten Up - Medical office communication system
- **Location**: `/Users/cadams/src/github.com/ryaminal/lighten-up/lighten_up`

## Code Quality Checks

**REQUIRED: Run these commands after EVERY code change:**

### 1. Analysis (ALWAYS RUN FIRST)
```bash
flutter analyze
```
- **When**: After creating/modifying ANY Dart file
- **Why**: Catches errors, warnings, and linting issues
- **Action**: Fix ALL errors before proceeding. Address warnings when practical.

### 2. Formatting (ALWAYS RUN)
```bash
dart format lib/ test/
```
- **When**: After any code modification
- **Why**: Ensures consistent code style across the project
- **Action**: Always format before considering a task complete

### 3. Code Generation (WHEN NEEDED)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
- **When**: After modifying files with `@freezed`, `@JsonSerializable`, or `@riverpod` annotations
- **Why**: Generates necessary `.freezed.dart`, `.g.dart`, and `.riverpod.dart` files
- **Action**: Run whenever you see errors about missing generated files

### 4. Tests (ALWAYS RUN)
```bash
flutter test
```
- **When**: After any code changes, especially to core logic
- **Why**: Ensures changes don't break existing functionality
- **Action**: All tests must pass. If tests fail, fix the code or update the tests with user approval

### 5. Dependency Check (WHEN NEEDED)
```bash
flutter pub get
```
- **When**: After modifying `pubspec.yaml`
- **Why**: Installs/updates dependencies
- **Action**: Run and verify no conflicts

## Development Workflow

**Standard workflow for code changes:**

1. Make code changes
2. Run `flutter pub run build_runner build --delete-conflicting-outputs` (if using generated code)
3. Run `dart format lib/ test/`
4. Run `flutter analyze`
5. Fix any errors/warnings
6. Run `flutter test`
7. Verify all tests pass
8. Mark task as complete

## SOLID Principles & Clean Code

**MANDATORY: All code MUST follow SOLID principles and clean code practices.**

### File Size Guidelines (STRICTLY ENFORCED)

**Target file sizes:**
- **Widgets**: 150-250 lines per file (maximum)
- **Providers**: 200-300 lines (state management logic only)
- **Services/Infrastructure**: 250-350 lines (if doing ONE job well)
- **Models**: Any size (but prefer smaller, focused models)
- **Generated files** (*.g.dart, *.freezed.dart): Ignore line counts

**When a file exceeds these limits:**
1. STOP and analyze the file structure
2. Identify logical separation points
3. Extract widgets, functions, or classes to separate files
4. Use composition over large monolithic files
5. Create a folder structure for related components

**Example:**
```
# BAD: One large file
lib/widgets/notification_dock.dart (500+ lines)

# GOOD: Modular structure
lib/widgets/notification_dock/
  notification_dock.dart       (150 lines - orchestrator)
  dock_header.dart            (70 lines)
  status_toggle.dart          (130 lines)
  alert_section.dart          (170 lines)
  dock_footer.dart            (71 lines)
```

### SOLID Principles Explained

#### 1. Single Responsibility Principle (SRP)
**"A class should have one, and only one, reason to change."**

**In Practice:**
- Each widget has ONE clear purpose
- Each provider manages ONE piece of state
- Each service handles ONE domain concern

**Good Example:**
```dart
// GOOD: Single responsibility
class DockHeader extends StatelessWidget {
  // Only handles displaying the header
  final User? user;
  final VoidCallback onMenuTap;
  // ...
}

class StatusToggle extends StatelessWidget {
  // Only handles status selection
  final UserStatus selectedStatus;
  final ValueChanged<UserStatus> onStatusChanged;
  // ...
}
```

**Bad Example:**
```dart
// BAD: Multiple responsibilities
class NotificationDock extends StatelessWidget {
  // Handles: header, status, alerts, footer, logic, state, etc.
  // 500+ lines of mixed concerns
  // ...
}
```

#### 2. Open/Closed Principle (OCP)
**"Software entities should be open for extension, but closed for modification."**

**In Practice:**
- Widgets are extensible via props (not by modifying code)
- Use callbacks for behavior customization
- Use composition to add features

**Good Example:**
```dart
// GOOD: Extensible via props
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final Color? customColor;
  
  // Behavior can be customized without modifying the widget
}
```

#### 3. Liskov Substitution Principle (LSP)
**"Derived classes must be substitutable for their base classes."**

**In Practice:**
- Consistent prop interfaces across similar widgets
- Child classes honor parent contracts
- No surprising behavior changes

**Good Example:**
```dart
// GOOD: All status buttons have same interface
class StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  // All instances work the same way
}
```

#### 4. Interface Segregation Principle (ISP)
**"Clients should not be forced to depend on interfaces they don't use."**

**In Practice:**
- Widgets only require props they actually use
- Don't pass entire objects when only one field is needed
- Keep callback signatures focused

**Good Example:**
```dart
// GOOD: Only requires what it needs
class UserAvatar extends StatelessWidget {
  final String initials;  // Not the entire User object
  final Color? backgroundColor;
}

// BAD: Requires entire object when only one field is used
class UserAvatar extends StatelessWidget {
  final User user;  // Forces dependency on entire User class
}
```

#### 5. Dependency Inversion Principle (DIP)
**"Depend on abstractions, not concretions."**

**In Practice:**
- Depend on callbacks/data models, not concrete implementations
- Use Riverpod providers for dependency injection
- Use repository interfaces, not direct API calls

**Good Example:**
```dart
// GOOD: Depends on abstraction (callback)
class DockFooter extends StatelessWidget {
  final VoidCallback onLogout;  // Don't care HOW logout happens
}

// In parent:
DockFooter(
  onLogout: () => ref.read(authProvider.notifier).logout(),
)
```

### Clean Code Practices

#### Naming Conventions
- **Classes/Widgets**: `PascalCase` (e.g., `NotificationDock`, `AlertCard`)
- **Files**: `snake_case` (e.g., `notification_dock.dart`, `alert_card.dart`)
- **Variables/Functions**: `camelCase` (e.g., `selectedStatus`, `handleLogout`)
- **Constants**: `lowerCamelCase` (e.g., `primaryColor`) or `SCREAMING_SNAKE_CASE` for true constants
- **Private members**: Prefix with `_` (e.g., `_handleTap`, `_AlertCard`)

#### Function/Method Guidelines
- **Keep functions short**: 20 lines or fewer (ideal), 50 lines maximum
- **One level of abstraction**: Don't mix high-level logic with low-level details
- **Descriptive names**: `_handleAlertTap(Alert alert)` not `_tap(Alert a)`
- **Avoid side effects**: Functions should do ONE thing clearly
- **Early returns**: Reduce nesting with guard clauses

**Good Example:**
```dart
void _handleAlertTap(Alert alert) {
  if (alert.isResolved) return;  // Guard clause
  
  // Single responsibility: navigate to alert details
  context.push('/alerts/${alert.id}');
}
```

#### Widget Organization Pattern
```dart
/// Widget documentation
class MyWidget extends StatelessWidget {
  // 1. Props (grouped logically)
  final String title;
  final VoidCallback onTap;
  
  // 2. Constructor
  const MyWidget({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  // 3. Build method (should be readable at a glance)
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildContent(),
    );
  }
  
  // 4. Private helper methods (extract complex logic)
  Widget _buildContent() {
    // ...
  }
  
  // 5. Private computed properties
  Color get _backgroundColor => isActive ? Colors.blue : Colors.grey;
}
```

#### Code Organization Within Files
```dart
// 1. Imports (grouped: dart, flutter, packages, project)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:third_party/package.dart';

import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/data/models/user.dart';

// 2. Constants (if any)
const double _kDefaultPadding = 16.0;

// 3. Main public class

// 4. Private helper classes (if small and related)
```

#### Comments & Documentation
- **DO**: Write dartdoc comments for public APIs
- **DO**: Explain WHY, not WHAT (code should be self-explanatory)
- **DON'T**: Write obvious comments
- **DON'T**: Comment out code (delete it, use git history)

**Good Example:**
```dart
/// Displays user status with Available/Busy/Away options.
/// 
/// The selected status is persisted to user preferences
/// and synced across devices via the backend.
class StatusToggle extends StatelessWidget {
  // ...
}

// GOOD: Explains WHY
// Using debounce to avoid overwhelming the API with search requests
final debouncedSearch = Debouncer(milliseconds: 300);

// BAD: States the obvious
// This is a container
Container(
  // Setting the color to blue
  color: Colors.blue,
)
```

### Code Smells to Avoid

#### 1. God Objects/Classes
- **Symptom**: File >300 lines, does many things
- **Fix**: Extract components following SRP

#### 2. Long Methods
- **Symptom**: Method >50 lines, hard to understand
- **Fix**: Extract helper methods, simplify logic

#### 3. Primitive Obsession
- **Symptom**: Using strings/ints instead of domain objects
- **Fix**: Create value objects or enums

**Bad Example:**
```dart
void updateStatus(String status) {  // What values are valid?
  if (status == 'online' || status == 'busy' || status == 'away') {
    // ...
  }
}
```

**Good Example:**
```dart
enum UserStatus { online, busy, away }

void updateStatus(UserStatus status) {  // Type-safe!
  // ...
}
```

#### 4. Feature Envy
- **Symptom**: Method uses more from another class than its own
- **Fix**: Move method to the class it envies

#### 5. Duplicate Code
- **Symptom**: Same logic in multiple places
- **Fix**: Extract to shared function/widget

### Flutter-Specific Rules

#### Never:
- Break existing tests without explicit approval
- Commit secrets or API keys
- Use `dynamic` types without justification
- Ignore analyzer warnings without documenting why
- Create widgets without keys for lists
- Use `print()` for logging (use AppLogger)
- Hard-code strings that should be localized
- Skip error handling in async operations
- Mutate state directly (use proper state management)
- Create files >300 lines without refactoring
- Mix business logic with UI code
- Use global state (use Riverpod providers)

#### Always:
- Use `const` constructors when possible
- Add `@override` annotations
- Handle null safety properly
- Use meaningful, descriptive variable names
- Document public APIs with dartdoc comments
- Use proper error handling (try-catch with specific exceptions)
- Follow repository pattern for data access
- Use Riverpod for dependency injection
- Keep widgets small and focused (single responsibility)
- Prefer composition over inheritance
- Use Freezed for immutable data models
- Leverage code generation (freezed, json_serializable, riverpod_generator)
- Extract complex widgets to separate files
- Use early returns to reduce nesting
- Follow the Boy Scout Rule: Leave code cleaner than you found it

### State Management (Riverpod):
- Use `ConsumerWidget` or `Consumer` for widgets that need state
- Prefer `@riverpod` annotations for providers
- Keep provider logic simple
- Use `AsyncValue` for async operations
- Handle loading, error, and data states properly

### File Organization:
- Follow the established folder structure:
  - `lib/core/` - Core utilities, theme, widgets
  - `lib/data/` - Models, repositories, data sources
  - `lib/domain/` - Business logic, use cases
  - `lib/presentation/` - UI screens, widgets, providers
- Name files using snake_case
- One class per file (except small helper classes)

### Architecture Patterns:
- **Clean Architecture**: Separation of concerns (data, domain, presentation)
- **Repository Pattern**: Abstract data sources
- **SOLID Principles**: Single responsibility, open/closed, etc.
- **Error Handling**: Use Result/Either types or try-catch with specific failures

### Performance:
- Use `const` constructors liberally
- Avoid rebuilds with proper keys
- Use `ListView.builder` for long lists
- Cache network responses locally (Hive)
- Debounce search inputs
- Use image caching (`cached_network_image`)

Before marking any task complete:

### Quality Checks
- [ ] `flutter analyze` shows no errors
- [ ] `flutter format` has been run
- [ ] Code generation completed (if needed)
- [ ] All tests pass (`flutter test`)

### SOLID Principles
- [ ] Single Responsibility: Each class/widget has one clear purpose
- [ ] Open/Closed: Components are extensible via props, not modification
- [ ] Liskov Substitution: Consistent interfaces across similar components
- [ ] Interface Segregation: Components only require what they use
- [ ] Dependency Inversion: Depends on abstractions (callbacks), not concretions

### Clean Code
- [ ] File size ≤ 250 lines (widgets) or ≤ 300 lines (providers/services)
- [ ] Functions ≤ 50 lines (ideally ≤ 20 lines)
- [ ] Meaningful, descriptive names (no abbreviations)
- [ ] Proper dartdoc comments for public APIs
- [ ] No code smells (god objects, long methods, duplicate code)
- [ ] Early returns used to reduce nesting
- [ ] No commented-out code

### Error Handling & Safety
- [ ] Error handling is present for all async operations
- [ ] Null safety is handled properly
- [ ] Widget keys are used where appropriate
- [ ] Logging uses AppLogger, not print()

### Architecture & Performance
- [ ] No hard-coded strings (use constants)
- [ ] Performance considerations addressed
- [ ] State management follows Riverpod patterns
- [ ] Follows repository pattern for data access
- [ ] `const` constructors used where possible

## Common Commands Reference

```bash
# Run app on Chrome (web)
flutter run -d chrome

# Run app on macOS
flutter run -d macos

# Run with hot reload
flutter run -d chrome --hot

# Build for web
flutter build web

# Clean and rebuild
flutter clean && flutter pub get

# Check outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Run specific test
flutter test test/path/to/test.dart

# Run tests with coverage
flutter test --coverage

# Check for Flutter issues
flutter doctor

# Format specific file
dart format lib/path/to/file.dart
```

## Debugging Tips

- Use `debugPrint()` for temporary debug output
- Use Flutter DevTools for performance profiling
- Check `flutter doctor` if builds fail
- Clear derived data: `flutter clean`
- Restart IDE if hot reload stops working
- Use `--verbose` flag for detailed error output

## Git Workflow

When committing changes:
1. Ensure all quality checks pass
2. Stage only relevant files
3. Write clear, concise commit messages
4. Don't commit generated files (already in .gitignore)
5. Don't commit IDE-specific files

---

**Remember: Quality over speed. Always run the quality checks before marking tasks complete.**
