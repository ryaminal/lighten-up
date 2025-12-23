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

## Dart/Flutter Language Standards

**Follow [Effective Dart](https://dart.dev/effective-dart) guidelines for all code.**

### const vs final (CRITICAL)

**Understanding the difference:**
- **`const`**: Compile-time constant (value known at compile time, deeply immutable)
- **`final`**: Runtime constant (value set once, but determined at runtime)

#### When to Use `const`

**PREFER `const` for:**
1. ✅ **Compile-time constant values** (literals, const constructors)
2. ✅ **Widget constructors** when all parameters are compile-time constants
3. ✅ **Collections** with compile-time constant elements
4. ✅ **Default parameter values**

**Examples:**
```dart
// ✅ GOOD: Compile-time constants
const double padding = 16.0;
const String appName = 'Lighten Up';
const List<String> supportedPlatforms = ['iOS', 'Android', 'Web'];
const TimeOfDay startTime = TimeOfDay(hour: 22, minute: 0);

// ✅ GOOD: const constructors with const values
const QuietHours(
  startTime: TimeOfDay(hour: 22, minute: 0),
  endTime: TimeOfDay(hour: 8, minute: 0),
  enabled: true,
);

// ✅ GOOD: const widgets (performance benefit)
const Text('Hello World');
const SizedBox(height: 16);
const Icon(Icons.notification_important);

// ✅ GOOD: const default parameters
Widget build(BuildContext context, {EdgeInsets padding = const EdgeInsets.all(16)}) {
  // ...
}
```

#### When to Use `final`

**PREFER `final` for:**
1. ✅ **Runtime values** (API responses, user input, DateTime.now())
2. ✅ **Widget constructor parameters** (can't be const if parent isn't const)
3. ✅ **Class fields** (unless they're compile-time constants)
4. ✅ **Local variables** that won't change after initialization

**Examples:**
```dart
// ✅ GOOD: Runtime values
final now = DateTime.now();  // Value determined at runtime
final user = await fetchUser();  // Async operation
final theme = Theme.of(context);  // Depends on context

// ✅ GOOD: Widget parameters (typical case)
class AlertCard extends StatelessWidget {
  final Alert alert;  // Runtime data, use final
  final VoidCallback? onTap;

  const AlertCard({super.key, required this.alert, this.onTap});
}

// ✅ GOOD: Class fields
class AuthRepository {
  final IHttpClient _httpClient;  // Dependency injection, use final

  AuthRepository({required IHttpClient httpClient}) : _httpClient = httpClient;
}

// ✅ GOOD: Local variables
void processData(List<int> numbers) {
  final sum = numbers.reduce((a, b) => a + b);  // Computed value
  final average = sum / numbers.length;
  print('Average: $average');
}
```

#### Common Patterns

**Pattern 1: const constructors with final fields**
```dart
// Class with const constructor
class AppColors {
  final Color primary;
  final Color secondary;

  // const constructor requires all fields to be final
  const AppColors({required this.primary, required this.secondary});
}

// Usage: Create compile-time constant instances
const lightColors = AppColors(primary: Colors.blue, secondary: Colors.green);
const darkColors = AppColors(primary: Colors.indigo, secondary: Colors.teal);
```

**Pattern 2: const in widget trees**
```dart
// ✅ GOOD: Use const for static widgets
Widget build(BuildContext context) {
  return Column(
    children: [
      const Text('Static title'),  // const - never changes
      Text(user.name),  // NOT const - dynamic data
      const SizedBox(height: 16),  // const - static spacing
      const Divider(),  // const - static widget
    ],
  );
}
```

**Pattern 3: Transitively const**
```dart
// ✅ GOOD: Everything is const all the way down
const QuietHours quietHours = QuietHours(
  startTime: TimeOfDay(hour: 22, minute: 0),  // const
  endTime: TimeOfDay(hour: 8, minute: 0),  // const
  enabled: true,  // const literal
);

// ❌ BAD: Can't be const if any part is non-const
final QuietHours quietHours = QuietHours(
  startTime: TimeOfDay.now(),  // Runtime value!
  endTime: TimeOfDay(hour: 8, minute: 0),
  enabled: true,
);
```

#### Common Mistakes

**❌ DON'T use const for runtime values:**
```dart
// ❌ ERROR: DateTime.now() is runtime value
const now = DateTime.now();  // Compilation error!

// ✅ CORRECT:
final now = DateTime.now();
```

**❌ DON'T use const redundantly:**
```dart
// ❌ BAD: Redundant const (already in const context)
const list = [const SizedBox(), const Text('Hello')];

// ✅ GOOD: Const context applies to children
const list = [SizedBox(), Text('Hello')];
```

**❌ DON'T forget const for compile-time constants:**
```dart
// ❌ BAD: Missing const (8 violations we just fixed!)
final startTime = TimeOfDay(hour: 22, minute: 0);  // Should be const

// ✅ GOOD:
const startTime = TimeOfDay(hour: 22, minute: 0);
```

### Type Annotations

**DO type annotate public APIs:**
```dart
// ✅ GOOD: Public API with type annotations
String formatTime(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
```

**CONSIDER omitting types for local variables (use type inference):**
```dart
// ✅ GOOD: Type inference for locals
final user = await fetchUser();  // Type inferred as User
final count = items.length;  // Type inferred as int
```

**DO annotate when inference fails or is unclear:**
```dart
// ✅ GOOD: Explicit when needed
final List<Widget> children = [];  // Empty list needs type
final dynamic jsonData = parseJson(response);  // Dynamic is intentional
```

### Null Safety

**DO handle nulls explicitly:**
```dart
// ✅ GOOD: Explicit null handling
final user = await fetchUser();
if (user != null) {
  print(user.name);
}

// ✅ GOOD: Null-aware operators
final name = user?.name ?? 'Guest';

// ✅ GOOD: Late initialization (when you're certain)
late final UserPreferences _prefs;

@override
void initState() {
  super.initState();
  _prefs = UserPreferences.load();
}
```

**DON'T use `!` (bang operator) without justification:**
```dart
// ❌ BAD: Potential null pointer exception
final name = user!.name;  // What if user is null?

// ✅ GOOD: Safe access
final name = user?.name ?? 'Guest';
```

### Effective Dart Quick Reference

**Key principles from [dart.dev/effective-dart](https://dart.dev/effective-dart):**
1. **PREFER** making fields and top-level variables `final`
2. **DO** use `const` for compile-time constants
3. **CONSIDER** making constructors `const` if the class supports it
4. **DO** follow a consistent rule for `var` and `final` on locals
5. **PREFER** using `??` (null-coalescing) to convert `null` to a default value
6. **AVOID** using `!` if `?` or `??` can be used instead
7. **DON'T** redundantly type annotate initialized local variables
8. **DO** annotate when inference doesn't work or is unclear

---

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

### SOLID Principles (Quick Reference)

Apply these principles to all code. See [Wikipedia: SOLID](https://en.wikipedia.org/wiki/SOLID) for detailed explanations.

#### 1. Single Responsibility Principle (SRP)
**Rule**: A class should have one, and only one, reason to change.

**Application:**
- Each widget has ONE clear purpose (display header, handle status selection, etc.)
- Each provider manages ONE piece of state
- Each service handles ONE domain concern
- **Anti-pattern**: 500-line widget handling header + status + alerts + footer + logic

**Example:**
```dart
// ✅ GOOD: Single responsibility
class DockHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onMenuTap;
}

class StatusToggle extends StatelessWidget {
  final UserStatus selectedStatus;
  final ValueChanged<UserStatus> onStatusChanged;
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
- **Use `const` constructors when possible** (compile-time constants for performance)
- **Make fields and variables `final`** (prefer immutability)
- Add `@override` annotations
- Handle null safety properly (use `?.` and `??` instead of `!`)
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
- **Adapter Pattern**: Wrap external dependencies with interfaces (see below)
- **SOLID Principles**: Single responsibility, open/closed, etc.
- **Error Handling**: Use Result/Either types or try-catch with specific failures

### Adapter Pattern (MANDATORY for Infrastructure)

**CRITICAL: All infrastructure dependencies MUST use the Adapter Pattern following Dependency Inversion Principle.**

#### What is the Adapter Pattern?

The Adapter Pattern wraps external libraries (HTTP clients, databases, storage, WebSockets) behind interface abstractions. This allows:
- **Easy Testing**: Mock implementations for unit tests
- **Flexibility**: Swap libraries without changing business logic
- **SOLID Compliance**: Follows Dependency Inversion Principle
- **No Vendor Lock-in**: Not tied to specific library implementations

#### When to Use Adapters

**ALWAYS use adapters for:**
1. ✅ HTTP/API clients (Dio, http)
2. ✅ Secure storage (FlutterSecureStorage)
3. ✅ Databases (sqflite, Hive, Drift)
4. ✅ WebSocket/Real-time clients (web_socket_channel, socket.io)
5. ✅ Local storage (SharedPreferences)
6. ✅ File system operations
7. ✅ External APIs (Firebase, AWS, etc.)

**DO NOT use adapters for:**
- ❌ Pure Dart utilities (no external dependencies)
- ❌ Flutter framework widgets
- ❌ Simple data models
- ❌ Riverpod providers themselves

#### Adapter Pattern Implementation

**Step 1: Create the Interface**

```dart
// lib/core/network/http_client_interface.dart

/// HTTP Client Interface - Abstraction for HTTP operations
/// Depend on this interface, not concrete implementations
abstract class IHttpClient {
  Future<HttpResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters});
  Future<HttpResponse<T>> post<T>(String path, {dynamic data});
  Future<HttpResponse<T>> put<T>(String path, {dynamic data});
  Future<HttpResponse<T>> delete<T>(String path);

  void setAccessToken(String? token);
  String? get accessToken;
  void close();
}

/// Response wrapper to decouple from Dio's Response class
class HttpResponse<T> {
  final T data;
  final int? statusCode;
  final Map<String, dynamic>? headers;

  HttpResponse({required this.data, this.statusCode, this.headers});
}
```

**Step 2: Create the Adapter**

```dart
// lib/core/network/dio_http_client.dart

import 'package:dio/dio.dart';
import 'package:lighten_up/core/network/http_client_interface.dart';

/// Dio adapter implementing IHttpClient interface
/// Wraps Dio to match our interface - easy to swap or mock
class DioHttpClient implements IHttpClient {
  late final Dio _dio;
  String? _accessToken;

  DioHttpClient({String? baseUrl, String? accessToken}) : _accessToken = accessToken {
    _dio = Dio(BaseOptions(baseUrl: baseUrl ?? ApiEndpoints.baseUrl));
  }

  @override
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  @override
  String? get accessToken => _accessToken;

  @override
  Future<HttpResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<T>(path, queryParameters: queryParameters);
      return HttpResponse.fromDioResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Implement other methods...

  @override
  void close() {
    _dio.close();
  }
}
```

**Step 3: Create Export Module (Optional but Recommended)**

```dart
// lib/core/network/api_client.dart

/// API Client - HTTP client abstraction layer
/// Use IHttpClient interface for all dependencies

library;

export 'http_client_interface.dart';
export 'dio_http_client.dart';
```

**Step 4: Use Interface in Providers**

```dart
// lib/presentation/providers/core_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lighten_up/core/network/http_client_interface.dart';
import 'package:lighten_up/core/network/dio_http_client.dart';

/// Provides IHttpClient instance (using Dio adapter)
/// Depends on interface, not concrete implementation
@Riverpod(keepAlive: true)
IHttpClient httpClient(Ref ref) {
  return DioHttpClient(); // Can easily swap for MockHttpClient in tests
}
```

**Step 5: Depend on Interface in Repositories**

```dart
// lib/data/repositories/auth_repository_impl.dart

import 'package:lighten_up/core/network/http_client_interface.dart';

class AuthRepositoryImpl implements AuthRepository {
  final IHttpClient _httpClient;  // ✅ Interface, not concrete class

  AuthRepositoryImpl({required IHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _httpClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }
}
```

#### Existing Adapters in the Project

**Current adapters (MUST use these):**

1. **HTTP Client** (`lib/core/network/`)
   - Interface: `IHttpClient`
   - Adapter: `DioHttpClient`
   - Export: `api_client.dart`
   - Purpose: HTTP requests to backend API

2. **Secure Storage** (`lib/core/storage/`)
   - Interface: `ISecureStorage`
   - Adapter: `FlutterSecureStorageAdapter`
   - Export: `secure_storage.dart`
   - Purpose: Encrypted storage for tokens, passwords, sensitive data

3. **WebSocket/Real-time Client** (`lib/core/network/`)
   - Interface: `IRealtimeClient`
   - Adapter: `WebSocketChannelAdapter`
   - Export: `websocket_client.dart`
   - Purpose: Real-time bidirectional communication

4. **NoSQL Database** (`lib/core/storage/`)
   - Interface: `IDatabase` and `IDatabaseBox<T>`
   - Adapter: `HiveDatabaseAdapter` and `HiveBoxAdapter<T>`
   - Export: `database_helper.dart`
   - Purpose: Local NoSQL database for caching and offline storage
   - Currently using: **Hive** (key-value store)
   - Can swap for: Isar, ObjectBox, Realm, Firebase/Firestore

#### Testing with Adapters

**Adapters make testing easy:**

```dart
// test/mocks/mock_http_client.dart

class MockHttpClient implements IHttpClient {
  @override
  Future<HttpResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    // Return mock data
    return HttpResponse(data: {'mock': 'data'} as T);
  }

  // Implement other methods with mock data...
}

// In tests:
test('login returns user data', () async {
  final mockClient = MockHttpClient();
  final repository = AuthRepositoryImpl(httpClient: mockClient);

  final result = await repository.login(LoginRequest(email: 'test@example.com'));

  expect(result.user.email, 'test@example.com');
});
```

#### Adapter Pattern Checklist

When creating new adapters:

- [ ] Create `I<Name>` interface in appropriate directory
- [ ] Define all required methods in interface
- [ ] Create `<Library><Name>Adapter` class implementing interface
- [ ] Add `@override` annotations to all implemented methods
- [ ] Create export module file (optional but recommended)
- [ ] Update providers to return interface type
- [ ] Update all consumers to depend on interface type
- [ ] Run `flutter pub run build_runner build` if using Riverpod annotations
- [ ] Verify with `flutter analyze` and `flutter test`

#### Common Mistakes to Avoid

❌ **DON'T depend on concrete implementations:**
```dart
class AuthRepositoryImpl {
  final Dio _dio;  // ❌ Direct dependency on Dio
  AuthRepositoryImpl({required Dio dio}) : _dio = dio;
}
```

✅ **DO depend on interfaces:**
```dart
class AuthRepositoryImpl {
  final IHttpClient _httpClient;  // ✅ Depends on interface
  AuthRepositoryImpl({required IHttpClient httpClient}) : _httpClient = httpClient;
}
```

❌ **DON'T expose library-specific types:**
```dart
abstract class IHttpClient {
  Future<Response> get(String path);  // ❌ Exposes Dio's Response type
}
```

✅ **DO wrap library-specific types:**
```dart
abstract class IHttpClient {
  Future<HttpResponse> get(String path);  // ✅ Uses our wrapper type
}
```

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
- [ ] Infrastructure dependencies use Adapter Pattern (IHttpClient, ISecureStorage, etc.)
- [ ] `const` constructors used where possible
- [ ] Compile-time constants use `const`, runtime constants use `final`
- [ ] Effective Dart guidelines followed (type annotations, null safety)

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
