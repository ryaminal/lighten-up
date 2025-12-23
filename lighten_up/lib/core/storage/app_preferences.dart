import 'preferences_storage.dart';

/// App-specific convenience methods for PreferencesStorage
///
/// Provides type-safe accessors for common app settings
/// with sensible defaults.
extension AppPreferences on PreferencesStorage {
  // ========== Theme Settings ==========

  /// Set theme mode ('light', 'dark', or 'system')
  Future<bool> setThemeMode(String mode) async {
    return await setString(PreferencesStorage.keyThemeMode, mode);
  }

  /// Get theme mode (defaults to 'dark')
  Future<String> getThemeMode() async {
    return await getString(PreferencesStorage.keyThemeMode) ?? 'dark';
  }

  // ========== Sound & Notifications ==========

  /// Set sound enabled
  Future<bool> setSoundEnabled(bool enabled) async {
    return await setBool(PreferencesStorage.keySoundEnabled, enabled);
  }

  /// Get sound enabled (defaults to true)
  Future<bool> getSoundEnabled() async {
    return await getBool(PreferencesStorage.keySoundEnabled) ?? true;
  }

  /// Set vibration enabled
  Future<bool> setVibrationEnabled(bool enabled) async {
    return await setBool(PreferencesStorage.keyVibrationEnabled, enabled);
  }

  /// Get vibration enabled (defaults to true)
  Future<bool> getVibrationEnabled() async {
    return await getBool(PreferencesStorage.keyVibrationEnabled) ?? true;
  }

  /// Set notifications enabled
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool(PreferencesStorage.keyNotificationsEnabled, enabled);
  }

  /// Get notifications enabled (defaults to true)
  Future<bool> getNotificationsEnabled() async {
    return await getBool(PreferencesStorage.keyNotificationsEnabled) ?? true;
  }

  // ========== Localization ==========

  /// Set language code
  Future<bool> setLanguage(String languageCode) async {
    return await setString(PreferencesStorage.keyLanguage, languageCode);
  }

  /// Get language code (defaults to 'en')
  Future<String> getLanguage() async {
    return await getString(PreferencesStorage.keyLanguage) ?? 'en';
  }

  // ========== Onboarding & Sync ==========

  /// Set onboarding completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await setBool(PreferencesStorage.keyOnboardingCompleted, completed);
  }

  /// Get onboarding completed (defaults to false)
  Future<bool> getOnboardingCompleted() async {
    return await getBool(PreferencesStorage.keyOnboardingCompleted) ?? false;
  }

  /// Set last sync time
  Future<bool> setLastSyncTime(DateTime dateTime) async {
    return await setString(
      PreferencesStorage.keyLastSyncTime,
      dateTime.toIso8601String(),
    );
  }

  /// Get last sync time (returns null if never synced)
  Future<DateTime?> getLastSyncTime() async {
    final str = await getString(PreferencesStorage.keyLastSyncTime);
    return str != null ? DateTime.tryParse(str) : null;
  }

  // ========== Privacy & Security ==========

  /// Set auto-lock duration in seconds
  Future<bool> setAutoLockDuration(int seconds) async {
    return await setInt(PreferencesStorage.keyAutoLockDuration, seconds);
  }

  /// Get auto-lock duration in seconds (defaults to 300 = 5 minutes)
  Future<int> getAutoLockDuration() async {
    return await getInt(PreferencesStorage.keyAutoLockDuration) ?? 300;
  }

  /// Set privacy lock enabled
  Future<bool> setPrivacyLockEnabled(bool enabled) async {
    return await setBool(PreferencesStorage.keyPrivacyLockEnabled, enabled);
  }

  /// Get privacy lock enabled (defaults to false)
  Future<bool> getPrivacyLockEnabled() async {
    return await getBool(PreferencesStorage.keyPrivacyLockEnabled) ?? false;
  }
}
