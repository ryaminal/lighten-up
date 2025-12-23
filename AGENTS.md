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

## Flutter-Specific Rules

### Never:
- Break existing tests without explicit approval
- Commit secrets or API keys
- Use `dynamic` types without justification
- Ignore analyzer warnings without documenting why
- Create widgets without keys for lists
- Use `print()` for logging (use AppLogger)
- Hard-code strings that should be localized
- Skip error handling in async operations
- Mutate state directly (use proper state management)

### Always:
- Use `const` constructors when possible
- Add `@override` annotations
- Handle null safety properly
- Use meaningful variable names
- Document public APIs with dartdoc comments
- Use proper error handling (try-catch with specific exceptions)
- Follow repository pattern for data access
- Use Riverpod for dependency injection
- Keep widgets small and focused (single responsibility)
- Prefer composition over inheritance
- Use Freezed for immutable data models
- Leverage code generation (freezed, json_serializable, riverpod_generator)

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

## Code Review Checklist

Before marking any task complete:

- [ ] `flutter analyze` shows no errors
- [ ] `flutter format` has been run
- [ ] Code generation completed (if needed)
- [ ] All tests pass (`flutter test`)
- [ ] New code has appropriate comments
- [ ] Error handling is present
- [ ] Null safety is handled
- [ ] Widget keys are used where appropriate
- [ ] No hard-coded strings (use constants)
- [ ] Logging uses AppLogger, not print()
- [ ] Performance considerations addressed

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
