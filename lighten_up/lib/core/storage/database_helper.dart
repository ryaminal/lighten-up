import 'package:hive_flutter/hive_flutter.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Helper class for managing Hive database operations
/// Used for caching and offline data storage
class DatabaseHelper {
  static bool _initialized = false;

  // Box names
  static const String boxMessages = 'messages';
  static const String boxNotifications = 'notifications';
  static const String boxAlerts = 'alerts';
  static const String boxPatients = 'patients';
  static const String boxStaff = 'staff';
  static const String boxSettings = 'settings';
  static const String boxCache = 'cache';

  /// Initialize Hive
  static Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('DatabaseHelper: Already initialized');
      return;
    }

    try {
      await Hive.initFlutter();
      _initialized = true;
      AppLogger.info('DatabaseHelper: Initialized successfully');
    } catch (e) {
      AppLogger.error('DatabaseHelper init error: $e');
      throw CacheException(message: 'Failed to initialize database', data: e);
    }
  }

  /// Open a box
  static Future<Box<T>> openBox<T>(String boxName) async {
    try {
      if (!_initialized) {
        await init();
      }

      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }

      final box = await Hive.openBox<T>(boxName);
      AppLogger.debug('DatabaseHelper: Opened box: $boxName');
      return box;
    } catch (e) {
      AppLogger.error('DatabaseHelper openBox error: $e');
      throw CacheException(message: 'Failed to open box: $boxName', data: e);
    }
  }

  /// Close a box
  static Future<void> closeBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
        AppLogger.debug('DatabaseHelper: Closed box: $boxName');
      }
    } catch (e) {
      AppLogger.error('DatabaseHelper closeBox error: $e');
      throw CacheException(message: 'Failed to close box: $boxName', data: e);
    }
  }

  /// Delete a box
  static Future<void> deleteBox(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      AppLogger.info('DatabaseHelper: Deleted box: $boxName');
    } catch (e) {
      AppLogger.error('DatabaseHelper deleteBox error: $e');
      throw CacheException(message: 'Failed to delete box: $boxName', data: e);
    }
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    try {
      await Hive.close();
      AppLogger.info('DatabaseHelper: Closed all boxes');
    } catch (e) {
      AppLogger.error('DatabaseHelper closeAll error: $e');
      throw CacheException(message: 'Failed to close all boxes', data: e);
    }
  }

  /// Delete all boxes (clear all data)
  static Future<void> deleteAll() async {
    try {
      await Hive.deleteFromDisk();
      AppLogger.warning('DatabaseHelper: Deleted all data from disk');
    } catch (e) {
      AppLogger.error('DatabaseHelper deleteAll error: $e');
      throw CacheException(message: 'Failed to delete all boxes', data: e);
    }
  }

  /// Register type adapter for custom objects
  static void registerAdapter<T>(TypeAdapter<T> adapter) {
    try {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter<T>(adapter);
        AppLogger.debug(
          'DatabaseHelper: Registered adapter: ${adapter.typeId}',
        );
      }
    } catch (e) {
      AppLogger.error('DatabaseHelper registerAdapter error: $e');
      throw CacheException(message: 'Failed to register adapter', data: e);
    }
  }
}

/// Generic repository for Hive box operations
class HiveRepository<T> {
  final String boxName;
  Box<T>? _box;

  HiveRepository(this.boxName);

  /// Get the box, opening it if necessary
  Future<Box<T>> get box async {
    _box ??= await DatabaseHelper.openBox<T>(boxName);
    return _box!;
  }

  /// Put a value with a key
  Future<void> put(String key, T value) async {
    try {
      final b = await box;
      await b.put(key, value);
      AppLogger.debug('HiveRepository[$boxName]: Put key: $key');
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] put error: $e');
      throw CacheException(
        message: 'Failed to put value in box: $boxName',
        data: e,
      );
    }
  }

  /// Get a value by key
  Future<T?> get(String key) async {
    try {
      final b = await box;
      return b.get(key);
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] get error: $e');
      return null;
    }
  }

  /// Delete a value by key
  Future<void> delete(String key) async {
    try {
      final b = await box;
      await b.delete(key);
      AppLogger.debug('HiveRepository[$boxName]: Deleted key: $key');
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] delete error: $e');
      throw CacheException(
        message: 'Failed to delete key from box: $boxName',
        data: e,
      );
    }
  }

  /// Get all values
  Future<List<T>> getAll() async {
    try {
      final b = await box;
      return b.values.toList();
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] getAll error: $e');
      return [];
    }
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    try {
      final b = await box;
      return b.keys.cast<String>().toList();
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] getAllKeys error: $e');
      return [];
    }
  }

  /// Clear all data in the box
  Future<void> clear() async {
    try {
      final b = await box;
      await b.clear();
      AppLogger.info('HiveRepository[$boxName]: Cleared all data');
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] clear error: $e');
      throw CacheException(message: 'Failed to clear box: $boxName', data: e);
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final b = await box;
      return b.containsKey(key);
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] containsKey error: $e');
      return false;
    }
  }

  /// Get count of items
  Future<int> count() async {
    try {
      final b = await box;
      return b.length;
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] count error: $e');
      return 0;
    }
  }

  /// Put multiple values at once
  Future<void> putAll(Map<String, T> entries) async {
    try {
      final b = await box;
      await b.putAll(entries);
      AppLogger.debug(
        'HiveRepository[$boxName]: Put ${entries.length} entries',
      );
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] putAll error: $e');
      throw CacheException(
        message: 'Failed to put multiple values in box: $boxName',
        data: e,
      );
    }
  }

  /// Delete multiple keys at once
  Future<void> deleteAll(List<String> keys) async {
    try {
      final b = await box;
      await b.deleteAll(keys);
      AppLogger.debug('HiveRepository[$boxName]: Deleted ${keys.length} keys');
    } catch (e) {
      AppLogger.error('HiveRepository[$boxName] deleteAll error: $e');
      throw CacheException(
        message: 'Failed to delete multiple keys from box: $boxName',
        data: e,
      );
    }
  }

  /// Watch for changes in the box
  Stream<BoxEvent> watch({String? key}) {
    return _box!.watch(key: key);
  }

  /// Close the box
  Future<void> close() async {
    if (_box != null) {
      await DatabaseHelper.closeBox(boxName);
      _box = null;
    }
  }
}
