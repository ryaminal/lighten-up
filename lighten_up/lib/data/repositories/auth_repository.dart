import 'package:lighten_up/data/models/user.dart';

/// Authentication repository interface - core authentication operations
/// Follows Interface Segregation Principle - clients only depend on what they need
abstract class IAuthenticationRepository {
  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request);

  /// Logout current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}

/// Token management repository interface
abstract class ITokenRepository {
  /// Refresh access token
  Future<AuthResponse> refreshToken();
}

/// User profile repository interface
abstract class IUserRepository {
  /// Get current user
  Future<User> getCurrentUser();

  /// Update user profile
  Future<User> updateProfile(User user);
}

/// Security operations repository interface
abstract class ISecurityRepository {
  /// Verify PIN for privacy lock
  Future<bool> verifyPin(PinRequest request);

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

/// Legacy interface for backward compatibility
/// Combines all auth-related operations
/// Use focused interfaces above for new code
abstract class AuthRepository
    implements
        IAuthenticationRepository,
        ITokenRepository,
        IUserRepository,
        ISecurityRepository {
  // This interface exists for backward compatibility
  // New code should use the focused interfaces above
}
