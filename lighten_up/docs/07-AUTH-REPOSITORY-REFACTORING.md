# Auth Repository Refactoring - Interface Segregation Principle

## Overview

The authentication repository has been refactored to follow the **Interface Segregation Principle (ISP)**. Instead of one large interface with all operations, we now have focused interfaces that allow clients to depend only on what they need.

## Focused Interfaces

### 1. `IAuthenticationRepository` - Core Authentication
Used for: Login, logout, authentication checks

```dart
abstract class IAuthenticationRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<void> logout();
  Future<bool> isAuthenticated();
}
```

**When to use:** Components that only need to authenticate users (login screens, auth guards).

### 2. `ITokenRepository` - Token Management
Used for: Token refresh operations

```dart
abstract class ITokenRepository {
  Future<AuthResponse> refreshToken();
}
```

**When to use:** HTTP interceptors, token refresh middleware.

### 3. `IUserRepository` - User Profile Operations
Used for: Getting and updating user profiles

```dart
abstract class IUserRepository {
  Future<User> getCurrentUser();
  Future<User> updateProfile(User user);
}
```

**When to use:** Profile screens, user settings, user display components.

### 4. `ISecurityRepository` - Security Operations
Used for: PIN verification, password changes

```dart
abstract class ISecurityRepository {
  Future<bool> verifyPin(PinRequest request);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
```

**When to use:** Security screens, PIN lock features, password change flows.

### 5. `AuthRepository` - Composite Interface (Backward Compatible)
Combines all interfaces for components that need multiple operations.

```dart
abstract class AuthRepository
    implements
        IAuthenticationRepository,
        ITokenRepository,
        IUserRepository,
        ISecurityRepository {
  // Full interface for backward compatibility
}
```

**When to use:** Full-featured auth providers, legacy code.

## Benefits

### 1. Smaller Dependencies
Components only depend on what they actually use:
```dart
// Before: Depended on entire AuthRepository (8 methods)
class LoginService {
  final AuthRepository _authRepository;
}

// After: Depends only on authentication operations (3 methods)
class LoginService {
  final IAuthenticationRepository _authRepository;
}
```

### 2. Easier Testing
Mock only the methods you need:
```dart
// Before: Had to mock all 8 methods
class MockAuthRepository implements AuthRepository {
  // Mock all methods even if only using login()
}

// After: Mock only what you test
class MockAuthRepository implements IAuthenticationRepository {
  // Only mock login(), logout(), isAuthenticated()
}
```

### 3. Better Code Organization
Clear separation of concerns:
- Authentication logic separate from profile management
- Token operations isolated from password operations
- Each interface has a single, focused responsibility

### 4. Flexible Implementations
Can implement interfaces separately if needed:
```dart
// Example: In-memory auth for testing
class InMemoryAuthRepository implements IAuthenticationRepository {
  // Only implement auth operations, not profiles or tokens
}

// Example: Separate profile service
class ProfileService implements IUserRepository {
  // Only implement profile operations
}
```

## Migration Guide

### For New Code
Use the most specific interface that meets your needs:

```dart
// Profile screen - only needs user operations
class ProfileProvider {
  final IUserRepository _userRepository;
  
  ProfileProvider(this._userRepository);
  
  Future<User> loadProfile() => _userRepository.getCurrentUser();
}

// Security screen - only needs security operations
class SecurityProvider {
  final ISecurityRepository _securityRepository;
  
  SecurityProvider(this._securityRepository);
  
  Future<bool> verifyPIN(String pin) => 
      _securityRepository.verifyPin(PinRequest(userId: '...', pin: pin));
}
```

### For Existing Code
No changes needed! `AuthRepositoryImpl` still implements the full `AuthRepository` interface:

```dart
// Existing code continues to work
final authRepository = AuthRepositoryImpl(...);
final authProvider = AuthProvider(authRepository); // ✓ Works

// Can also use focused interfaces
final IUserRepository userRepository = authRepository; // ✓ Works
final IAuthenticationRepository authRepo = authRepository; // ✓ Works
```

## Implementation

`AuthRepositoryImpl` implements the full `AuthRepository` interface (which extends all focused interfaces), so it works everywhere:

```dart
class AuthRepositoryImpl implements AuthRepository {
  // Implements all methods from all interfaces
  // Can be used as any of the focused interfaces
}
```

## Example: Refactoring a Component

### Before (violates ISP)
```dart
class UserProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Depends on entire AuthRepository, but only uses getCurrentUser()
    final authRepo = ref.watch(authRepositoryProvider);
    final user = await authRepo.getCurrentUser();
    return Text(user.fullName);
  }
}
```

### After (follows ISP)
```dart
// Create focused provider
@Riverpod(keepAlive: true)
IUserRepository userRepository(Ref ref) {
  return ref.watch(authRepositoryProvider); // AuthRepositoryImpl implements IUserRepository
}

class UserProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Depends only on user operations
    final userRepo = ref.watch(userRepositoryProvider);
    final user = await userRepo.getCurrentUser();
    return Text(user.fullName);
  }
}
```

## Next Steps

1. **Create focused providers** in `core_providers.dart` for each interface
2. **Refactor components** to use focused interfaces where appropriate
3. **Write focused tests** that mock only required operations
4. **Document** which interface each component should use

## Files Modified

- `lib/data/repositories/auth_repository.dart` - Split into focused interfaces
- `lib/data/repositories/auth_repository_impl.dart` - No changes (already implements full interface)
- This documentation file

## Backward Compatibility

✅ **100% backward compatible** - All existing code continues to work without changes.

The `AuthRepository` interface still exists and combines all operations, so existing components using it work exactly as before.
