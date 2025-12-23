import 'dart:async';

import 'package:lighten_up/core/storage/database_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Mock Database implementing IDatabase interface
/// Used for testing without requiring actual database initialization
/// All data is stored in memory and cleared when app restarts
class MockDatabase implements IDatabase {
  bool _initialized = false;
  final Map<String, MockDatabaseBox> _boxes = {};

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('MockDatabase: Already initialized');
      return;
    }

    AppLogger.info('MockDatabase: Initializing');
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simulate init delay
    _initialized = true;
    AppLogger.info('MockDatabase: Initialized successfully');
  }

  @override
  Future<IDatabaseBox<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      await init();
    }

    if (_boxes.containsKey(boxName)) {
      return _boxes[boxName]! as MockDatabaseBox<T>;
    }

    final box = MockDatabaseBox<T>(boxName);
    _boxes[boxName] = box;
    AppLogger.debug('MockDatabase: Opened box: $boxName');
    return box;
  }

  @override
  Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.close();
      _boxes.remove(boxName);
      AppLogger.debug('MockDatabase: Closed box: $boxName');
    }
  }

  @override
  Future<void> deleteBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.clear();
      _boxes.remove(boxName);
    }
    AppLogger.info('MockDatabase: Deleted box: $boxName');
  }

  @override
  Future<void> closeAll() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
    _initialized = false;
    AppLogger.info('MockDatabase: Closed all boxes');
  }

  @override
  Future<void> deleteAll() async {
    for (final box in _boxes.values) {
      await box.clear();
    }
    _boxes.clear();
    _initialized = false;
    AppLogger.warning('MockDatabase: Deleted all data');
  }

  @override
  void registerAdapter<T>(dynamic adapter) {
    // Mock implementation - no-op for testing
    AppLogger.debug('MockDatabase: Registered adapter (no-op)');
  }

  @override
  bool isBoxOpen(String boxName) {
    return _boxes.containsKey(boxName);
  }

  // ========== Test Helper Methods ==========

  /// Get all box names (for debugging/testing)
  List<String> debugGetBoxNames() {
    return _boxes.keys.toList();
  }

  /// Get box by name (for debugging/testing)
  MockDatabaseBox? debugGetBox(String boxName) {
    return _boxes[boxName];
  }
}

/// Mock Database Box implementing IDatabaseBox interface
class MockDatabaseBox<T> implements IDatabaseBox<T> {
  @override
  final String name;

  final Map<String, T> _data = {};
  final _changeController = StreamController<DatabaseEvent>.broadcast();
  bool _closed = false;

  MockDatabaseBox(this.name);

  @override
  Future<void> put(String key, T value) async {
    _checkClosed();
    _data[key] = value;
    _changeController.add(DatabaseEvent(key: key, value: value));
    AppLogger.debug('MockDatabaseBox[$name]: Put key: $key');
  }

  @override
  Future<T?> get(String key) async {
    _checkClosed();
    return _data[key];
  }

  @override
  Future<void> delete(String key) async {
    _checkClosed();
    final value = _data.remove(key);
    if (value != null) {
      _changeController.add(
        DatabaseEvent(key: key, value: value, deleted: true),
      );
    }
    AppLogger.debug('MockDatabaseBox[$name]: Deleted key: $key');
  }

  @override
  Future<List<T>> getAll() async {
    _checkClosed();
    return _data.values.toList();
  }

  @override
  Future<List<String>> getAllKeys() async {
    _checkClosed();
    return _data.keys.toList();
  }

  @override
  Future<void> clear() async {
    _checkClosed();
    _data.clear();
    _changeController.add(DatabaseEvent());
    AppLogger.info('MockDatabaseBox[$name]: Cleared all data');
  }

  @override
  Future<bool> containsKey(String key) async {
    _checkClosed();
    return _data.containsKey(key);
  }

  @override
  Future<int> count() async {
    _checkClosed();
    return _data.length;
  }

  @override
  Future<void> putAll(Map<String, T> entries) async {
    _checkClosed();
    _data.addAll(entries);
    for (final entry in entries.entries) {
      _changeController.add(DatabaseEvent(key: entry.key, value: entry.value));
    }
    AppLogger.debug('MockDatabaseBox[$name]: Put ${entries.length} entries');
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    _checkClosed();
    for (final key in keys) {
      final value = _data.remove(key);
      if (value != null) {
        _changeController.add(
          DatabaseEvent(key: key, value: value, deleted: true),
        );
      }
    }
    AppLogger.debug('MockDatabaseBox[$name]: Deleted ${keys.length} keys');
  }

  @override
  Stream<DatabaseEvent> watch({String? key}) {
    return _changeController.stream.where((event) {
      if (key == null) return true;
      return event.key == key;
    });
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _changeController.close();
    AppLogger.debug('MockDatabaseBox[$name]: Closed');
  }

  void _checkClosed() {
    if (_closed) {
      throw StateError('Box is closed');
    }
  }

  // ========== Test Helper Methods ==========

  /// Get all data (for debugging/testing)
  Map<String, T> debugGetAllData() {
    return Map.from(_data);
  }

  /// Check if box is closed (for debugging/testing)
  bool debugIsClosed() {
    return _closed;
  }

  /// Simulate data change event (for testing)
  void debugSimulateChange(String key, T value, {bool deleted = false}) {
    _changeController.add(
      DatabaseEvent(key: key, value: value, deleted: deleted),
    );
  }
}
