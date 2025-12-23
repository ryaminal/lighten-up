import 'package:lighten_up/data/models/user.dart';

/// Authentication repository interface
/// Defines contract for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request);

  /// Logout current user
  Future<void> logout();

  /// Refresh access token
  Future<AuthResponse> refreshToken();

  /// Verify PIN for privacy lock
  Future<bool> verifyPin(PinRequest request);

  /// Get current user
  Future<User> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Update user profile
  Future<User> updateProfile(User user);

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
