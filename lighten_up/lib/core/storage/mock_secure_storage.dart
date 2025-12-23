import 'package:lighten_up/core/storage/secure_storage_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Mock Secure Storage implementing ISecureStorage interface
/// Used for testing without requiring actual device secure storage
/// All data is stored in memory and cleared when app restarts
class MockSecureStorage implements ISecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
    AppLogger.debug('MockSecureStorage: Wrote key: $key');
  }

  @override
  Future<String?> read({required String key}) async {
    final value = _storage[key];
    AppLogger.debug(
      'MockSecureStorage: Read key: $key (${value != null ? "found" : "not found"})',
    );
    return value;
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
    AppLogger.debug('MockSecureStorage: Deleted key: $key');
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
    AppLogger.info('MockSecureStorage: Deleted all keys');
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    AppLogger.debug('MockSecureStorage: Read all keys');
    return Map.from(_storage);
  }

  // ========== Convenience methods for common operations ==========

  @override
  Future<void> saveAccessToken(String token) async {
    await write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await read(key: 'access_token');
  }

  @override
  Future<void> deleteAccessToken() async {
    await delete(key: 'access_token');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await write(key: 'refresh_token', value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await read(key: 'refresh_token');
  }

  @override
  Future<void> deleteRefreshToken() async {
    await delete(key: 'refresh_token');
  }

  @override
  Future<void> saveUserId(String userId) async {
    await write(key: 'user_id', value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return await read(key: 'user_id');
  }

  @override
  Future<void> deleteUserId() async {
    await delete(key: 'user_id');
  }

  @override
  Future<void> saveUserPin(String pin) async {
    await write(key: 'user_pin', value: pin);
  }

  @override
  Future<String?> getUserPin() async {
    return await read(key: 'user_pin');
  }

  @override
  Future<void> deleteUserPin() async {
    await delete(key: 'user_pin');
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await write(key: 'biometric_enabled', value: enabled.toString());
  }

  @override
  Future<bool> getBiometricEnabled() async {
    final value = await read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await write(key: 'device_id', value: deviceId);
  }

  @override
  Future<String?> getDeviceId() async {
    return await read(key: 'device_id');
  }

  @override
  Future<void> clearAuthData() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserId();
    await deleteUserPin();
    AppLogger.info('MockSecureStorage: Cleared all auth data');
  }

  /// Helper method to inspect current storage state (for debugging/testing)
  Map<String, String> debugGetAllKeys() {
    return Map.from(_storage);
  }

  /// Helper method to clear everything (for test teardown)
  Future<void> debugClearAll() async {
    _storage.clear();
    AppLogger.debug('MockSecureStorage: Debug cleared all data');
  }
}
