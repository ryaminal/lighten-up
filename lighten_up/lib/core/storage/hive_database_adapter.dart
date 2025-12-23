import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/storage/database_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Hive adapter implementing IDatabase interface
/// Follows Adapter Pattern - wraps Hive to match our interface
/// This allows easy mocking, testing, and swapping of database libraries
class HiveDatabaseAdapter implements IDatabase {
  bool _initialized = false;

  // Box names constants
  static const String boxMessages = 'messages';
  static const String boxNotifications = 'notifications';
  static const String boxAlerts = 'alerts';
  static const String boxPatients = 'patients';
  static const String boxStaff = 'staff';
  static const String boxSettings = 'settings';
  static const String boxCache = 'cache';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('HiveDatabaseAdapter: Already initialized');
      return;
    }

    try {
      await Hive.initFlutter();
      _initialized = true;
      AppLogger.info('HiveDatabaseAdapter: Initialized successfully');
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter init error: $e');
      throw CacheException(message: 'Failed to initialize database', data: e);
    }
  }

  @override
  Future<IDatabaseBox<T>> openBox<T>(String boxName) async {
    try {
      if (!_initialized) {
        await init();
      }

      Box<T> hiveBox;
      if (Hive.isBoxOpen(boxName)) {
        hiveBox = Hive.box<T>(boxName);
      } else {
        hiveBox = await Hive.openBox<T>(boxName);
      }

      AppLogger.debug('HiveDatabaseAdapter: Opened box: $boxName');
      return HiveBoxAdapter<T>(boxName, hiveBox);
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter openBox error: $e');
      throw CacheException(message: 'Failed to open box: $boxName', data: e);
    }
  }

  @override
  Future<void> closeBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
        AppLogger.debug('HiveDatabaseAdapter: Closed box: $boxName');
      }
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter closeBox error: $e');
      throw CacheException(message: 'Failed to close box: $boxName', data: e);
    }
  }

  @override
  Future<void> deleteBox(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      AppLogger.info('HiveDatabaseAdapter: Deleted box: $boxName');
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter deleteBox error: $e');
      throw CacheException(message: 'Failed to delete box: $boxName', data: e);
    }
  }

  @override
  Future<void> closeAll() async {
    try {
      await Hive.close();
      _initialized = false;
      AppLogger.info('HiveDatabaseAdapter: Closed all boxes');
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter closeAll error: $e');
      throw CacheException(message: 'Failed to close all boxes', data: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await Hive.deleteFromDisk();
      _initialized = false;
      AppLogger.warning('HiveDatabaseAdapter: Deleted all data from disk');
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter deleteAll error: $e');
      throw CacheException(message: 'Failed to delete all boxes', data: e);
    }
  }

  @override
  void registerAdapter<T>(dynamic adapter) {
    try {
      if (adapter is TypeAdapter<T>) {
        if (!Hive.isAdapterRegistered(adapter.typeId)) {
          Hive.registerAdapter<T>(adapter);
          AppLogger.debug(
            'HiveDatabaseAdapter: Registered adapter: ${adapter.typeId}',
          );
        }
      }
    } catch (e) {
      AppLogger.error('HiveDatabaseAdapter registerAdapter error: $e');
      throw CacheException(message: 'Failed to register adapter', data: e);
    }
  }

  @override
  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }
}

/// Hive Box adapter implementing IDatabaseBox interface
class HiveBoxAdapter<T> implements IDatabaseBox<T> {
  @override
  final String name;
  final Box<T> _box;

  HiveBoxAdapter(this.name, this._box);

  @override
  Future<void> put(String key, T value) async {
    try {
      await _box.put(key, value);
      AppLogger.debug('HiveBoxAdapter[$name]: Put key: $key');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] put error: $e');
      throw CacheException(
        message: 'Failed to put value in box: $name',
        data: e,
      );
    }
  }

  @override
  Future<T?> get(String key) async {
    try {
      return _box.get(key);
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] get error: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
      AppLogger.debug('HiveBoxAdapter[$name]: Deleted key: $key');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] delete error: $e');
      throw CacheException(
        message: 'Failed to delete key from box: $name',
        data: e,
      );
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      return _box.values.toList();
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] getAll error: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      return _box.keys.cast<String>().toList();
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] getAllKeys error: $e');
      return [];
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.clear();
      AppLogger.info('HiveBoxAdapter[$name]: Cleared all data');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] clear error: $e');
      throw CacheException(message: 'Failed to clear box: $name', data: e);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _box.containsKey(key);
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] containsKey error: $e');
      return false;
    }
  }

  @override
  Future<int> count() async {
    try {
      return _box.length;
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] count error: $e');
      return 0;
    }
  }

  @override
  Future<void> putAll(Map<String, T> entries) async {
    try {
      await _box.putAll(entries);
      AppLogger.debug('HiveBoxAdapter[$name]: Put ${entries.length} entries');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] putAll error: $e');
      throw CacheException(
        message: 'Failed to put multiple values in box: $name',
        data: e,
      );
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    try {
      await _box.deleteAll(keys);
      AppLogger.debug('HiveBoxAdapter[$name]: Deleted ${keys.length} keys');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] deleteAll error: $e');
      throw CacheException(
        message: 'Failed to delete multiple keys from box: $name',
        data: e,
      );
    }
  }

  @override
  Stream<DatabaseEvent> watch({String? key}) {
    // Convert Hive BoxEvent to our DatabaseEvent
    return _box.watch(key: key).map((boxEvent) {
      return DatabaseEvent(
        key: boxEvent.key?.toString(),
        value: boxEvent.value,
        deleted: boxEvent.deleted,
      );
    });
  }

  @override
  Future<void> close() async {
    try {
      await _box.close();
      AppLogger.debug('HiveBoxAdapter[$name]: Closed box');
    } catch (e) {
      AppLogger.error('HiveBoxAdapter[$name] close error: $e');
      throw CacheException(message: 'Failed to close box: $name', data: e);
    }
  }
}

/// Generic repository for database box operations
/// Provides a higher-level API over IDatabaseBox
class DatabaseRepository<T> {
  final String boxName;
  final IDatabase _database;
  IDatabaseBox<T>? _box;

  DatabaseRepository(this.boxName, this._database);

  /// Get the box, opening it if necessary
  Future<IDatabaseBox<T>> get box async {
    _box ??= await _database.openBox<T>(boxName);
    return _box!;
  }

  /// Put a value with a key
  Future<void> put(String key, T value) async {
    final b = await box;
    await b.put(key, value);
  }

  /// Get a value by key
  Future<T?> get(String key) async {
    final b = await box;
    return await b.get(key);
  }

  /// Delete a value by key
  Future<void> delete(String key) async {
    final b = await box;
    await b.delete(key);
  }

  /// Get all values
  Future<List<T>> getAll() async {
    final b = await box;
    return await b.getAll();
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    final b = await box;
    return await b.getAllKeys();
  }

  /// Clear all data in the box
  Future<void> clear() async {
    final b = await box;
    await b.clear();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    final b = await box;
    return await b.containsKey(key);
  }

  /// Get count of items
  Future<int> count() async {
    final b = await box;
    return await b.count();
  }

  /// Put multiple values at once
  Future<void> putAll(Map<String, T> entries) async {
    final b = await box;
    await b.putAll(entries);
  }

  /// Delete multiple keys at once
  Future<void> deleteAll(List<String> keys) async {
    final b = await box;
    await b.deleteAll(keys);
  }

  /// Watch for changes in the box
  Stream<DatabaseEvent> watch({String? key}) {
    return _box!.watch(key: key);
  }

  /// Close the box
  Future<void> close() async {
    if (_box != null) {
      await _box!.close();
      _box = null;
    }
  }
}
