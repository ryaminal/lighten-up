import 'package:shared_preferences/shared_preferences.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Wrapper around SharedPreferences for simple key-value storage
/// Used for non-sensitive app preferences and settings
class PreferencesStorage {
  SharedPreferences? _prefs;

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLanguage = 'language';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyAutoLockDuration = 'auto_lock_duration';
  static const String keyPrivacyLockEnabled = 'privacy_lock_enabled';

  /// Initialize SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('PreferencesStorage: Initialized');
    } catch (e) {
      AppLogger.error('PreferencesStorage init error: $e');
      throw CacheException(
        message: 'Failed to initialize preferences storage',
        data: e,
      );
    }
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ========== String operations ==========

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.setString(key, value);
      AppLogger.debug('PreferencesStorage: Set string key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage setString error: $e');
      throw CacheException(message: 'Failed to set string: $key', data: e);
    }
  }

  /// Get a string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage getString error: $e');
      return null;
    }
  }

  // ========== Int operations ==========

  /// Save an int value
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.setInt(key, value);
      AppLogger.debug('PreferencesStorage: Set int key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage setInt error: $e');
      throw CacheException(message: 'Failed to set int: $key', data: e);
    }
  }

  /// Get an int value
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage getInt error: $e');
      return null;
    }
  }

  // ========== Double operations ==========

  /// Save a double value
  Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.setDouble(key, value);
      AppLogger.debug('PreferencesStorage: Set double key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage setDouble error: $e');
      throw CacheException(message: 'Failed to set double: $key', data: e);
    }
  }

  /// Get a double value
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getDouble(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage getDouble error: $e');
      return null;
    }
  }

  // ========== Bool operations ==========

  /// Save a bool value
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.setBool(key, value);
      AppLogger.debug('PreferencesStorage: Set bool key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage setBool error: $e');
      throw CacheException(message: 'Failed to set bool: $key', data: e);
    }
  }

  /// Get a bool value
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage getBool error: $e');
      return null;
    }
  }

  // ========== List operations ==========

  /// Save a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.setStringList(key, value);
      AppLogger.debug('PreferencesStorage: Set string list key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage setStringList error: $e');
      throw CacheException(message: 'Failed to set string list: $key', data: e);
    }
  }

  /// Get a list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage getStringList error: $e');
      return null;
    }
  }

  // ========== Other operations ==========

  /// Remove a key
  Future<bool> remove(String key) async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.remove(key);
      AppLogger.debug('PreferencesStorage: Removed key: $key');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage remove error: $e');
      throw CacheException(message: 'Failed to remove key: $key', data: e);
    }
  }

  /// Clear all preferences
  Future<bool> clear() async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.clear();
      AppLogger.info('PreferencesStorage: Cleared all preferences');
      return result;
    } catch (e) {
      AppLogger.error('PreferencesStorage clear error: $e');
      throw CacheException(message: 'Failed to clear preferences', data: e);
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('PreferencesStorage containsKey error: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getKeys();
    } catch (e) {
      AppLogger.error('PreferencesStorage getKeys error: $e');
      return {};
    }
  }
}
