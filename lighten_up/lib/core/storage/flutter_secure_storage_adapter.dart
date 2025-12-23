import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/storage/secure_storage_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// FlutterSecureStorage adapter implementing ISecureStorage interface
/// Follows Adapter Pattern - wraps FlutterSecureStorage to match our interface
/// This allows easy mocking, testing, and swapping of secure storage libraries
class FlutterSecureStorageAdapter implements ISecureStorage {
  late final FlutterSecureStorage _storage;

  FlutterSecureStorageAdapter({FlutterSecureStorage? storage}) {
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      AppLogger.error('SecureStorage containsKey error: $e');
      return false;
    }
  }

  @override
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

  @override
  Future<void> saveAccessToken(String token) async {
    await write(key: keyAccessToken, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await read(key: keyAccessToken);
  }

  @override
  Future<void> deleteAccessToken() async {
    await delete(key: keyAccessToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await write(key: keyRefreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await read(key: keyRefreshToken);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await delete(key: keyRefreshToken);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await write(key: keyUserId, value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return await read(key: keyUserId);
  }

  @override
  Future<void> deleteUserId() async {
    await delete(key: keyUserId);
  }

  @override
  Future<void> saveUserPin(String pin) async {
    await write(key: keyUserPin, value: pin);
  }

  @override
  Future<String?> getUserPin() async {
    return await read(key: keyUserPin);
  }

  @override
  Future<void> deleteUserPin() async {
    await delete(key: keyUserPin);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await write(key: keyBiometricEnabled, value: enabled.toString());
  }

  @override
  Future<bool> getBiometricEnabled() async {
    final value = await read(key: keyBiometricEnabled);
    return value?.toLowerCase() == 'true';
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await write(key: keyDeviceId, value: deviceId);
  }

  @override
  Future<String?> getDeviceId() async {
    return await read(key: keyDeviceId);
  }

  @override
  Future<void> clearAuthData() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserId();
    await deleteUserPin();
    AppLogger.info('SecureStorage: Cleared all auth data');
  }
}
