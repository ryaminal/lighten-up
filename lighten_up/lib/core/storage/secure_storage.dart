import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Wrapper around FlutterSecureStorage for secure data persistence
/// Used for sensitive data like tokens, passwords, PINs, etc.
class SecureStorage {
  late final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage}) {
    _storage =
        storage ??
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );
  }

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserPin = 'user_pin';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyDeviceId = 'device_id';

  /// Write a value to secure storage
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('SecureStorage: Wrote key: $key');
    } catch (e) {
      AppLogger.error('SecureStorage write error: $e');
      throw CacheException(
        message: 'Failed to write to secure storage: $key',
        data: e,
      );
    }
  }

  /// Read a value from secure storage
  Future<String?> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      AppLogger.debug('SecureStorage: Read key: $key');
      return value;
    } catch (e) {
      AppLogger.error('SecureStorage read error: $e');
      throw CacheException(
        message: 'Failed to read from secure storage: $key',
        data: e,
      );
    }
  }

  /// Delete a value from secure storage
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('SecureStorage: Deleted key: $key');
    } catch (e) {
      AppLogger.error('SecureStorage delete error: $e');
      throw CacheException(
        message: 'Failed to delete from secure storage: $key',
        data: e,
      );
    }
  }

  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('SecureStorage: Deleted all keys');
    } catch (e) {
      AppLogger.error('SecureStorage deleteAll error: $e');
      throw CacheException(
        message: 'Failed to delete all from secure storage',
        data: e,
      );
    }
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      AppLogger.error('SecureStorage containsKey error: $e');
      return false;
    }
  }

  /// Read all keys from secure storage
  Future<Map<String, String>> readAll() async {
    try {
      final all = await _storage.readAll();
      AppLogger.debug('SecureStorage: Read all keys');
      return all;
    } catch (e) {
      AppLogger.error('SecureStorage readAll error: $e');
      throw CacheException(
        message: 'Failed to read all from secure storage',
        data: e,
      );
    }
  }

  // ========== Convenience methods for common operations ==========

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await write(key: keyAccessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await read(key: keyAccessToken);
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await delete(key: keyAccessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await write(key: keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await read(key: keyRefreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await delete(key: keyRefreshToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await write(key: keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await read(key: keyUserId);
  }

  /// Delete user ID
  Future<void> deleteUserId() async {
    await delete(key: keyUserId);
  }

  /// Save user PIN
  Future<void> saveUserPin(String pin) async {
    await write(key: keyUserPin, value: pin);
  }

  /// Get user PIN
  Future<String?> getUserPin() async {
    return await read(key: keyUserPin);
  }

  /// Delete user PIN
  Future<void> deleteUserPin() async {
    await delete(key: keyUserPin);
  }

  /// Save biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    await write(key: keyBiometricEnabled, value: enabled.toString());
  }

  /// Get biometric enabled status
  Future<bool> getBiometricEnabled() async {
    final value = await read(key: keyBiometricEnabled);
    return value?.toLowerCase() == 'true';
  }

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await write(key: keyDeviceId, value: deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await read(key: keyDeviceId);
  }

  /// Clear all authentication data (tokens, user ID, etc.)
  Future<void> clearAuthData() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserId();
    await deleteUserPin();
    AppLogger.info('SecureStorage: Cleared all auth data');
  }
}
