/// Secure Storage Interface - Abstraction for secure data persistence
///
/// This interface defines the contract for secure storage operations.
/// Follows Dependency Inversion Principle - depend on this interface, not concrete implementations.
///
/// Use this interface for all dependencies to enable easy testing, mocking, and swapping of storage libraries.
abstract class ISecureStorage {
  // ========== Core storage operations ==========

  /// Write a value to secure storage
  Future<void> write({required String key, required String value});

  /// Read a value from secure storage
  /// Returns null if the key doesn't exist
  Future<String?> read({required String key});

  /// Delete a value from secure storage
  Future<void> delete({required String key});

  /// Delete all values from secure storage
  Future<void> deleteAll();

  /// Check if a key exists in secure storage
  Future<bool> containsKey({required String key});

  /// Read all keys and values from secure storage
  Future<Map<String, String>> readAll();

  // ========== Convenience methods for common operations ==========
  // These provide a higher-level API for common use cases

  /// Save access token
  Future<void> saveAccessToken(String token);

  /// Get access token
  Future<String?> getAccessToken();

  /// Delete access token
  Future<void> deleteAccessToken();

  /// Save refresh token
  Future<void> saveRefreshToken(String token);

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Delete refresh token
  Future<void> deleteRefreshToken();

  /// Save user ID
  Future<void> saveUserId(String userId);

  /// Get user ID
  Future<String?> getUserId();

  /// Delete user ID
  Future<void> deleteUserId();

  /// Save user PIN
  Future<void> saveUserPin(String pin);

  /// Get user PIN
  Future<String?> getUserPin();

  /// Delete user PIN
  Future<void> deleteUserPin();

  /// Save biometric enabled status
  Future<void> setBiometricEnabled(bool enabled);

  /// Get biometric enabled status
  Future<bool> getBiometricEnabled();

  /// Save device ID
  Future<void> saveDeviceId(String deviceId);

  /// Get device ID
  Future<String?> getDeviceId();

  /// Clear all authentication data (tokens, user ID, PIN, etc.)
  Future<void> clearAuthData();
}
