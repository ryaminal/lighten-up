/// Database Interface - Abstraction for local database operations
///
/// This interface defines the contract for local database/cache operations.
/// Follows Dependency Inversion Principle - depend on this interface, not concrete implementations.
///
/// Use this interface for all dependencies to enable easy testing, mocking, and swapping of database libraries.

library;

import 'dart:async';

/// Database initialization and management interface
abstract class IDatabase {
  /// Initialize the database
  Future<void> init();

  /// Check if database is initialized
  bool get isInitialized;

  /// Open a box/collection with the given name
  Future<IDatabaseBox<T>> openBox<T>(String boxName);

  /// Close a box/collection
  Future<void> closeBox(String boxName);

  /// Delete a box/collection from disk
  Future<void> deleteBox(String boxName);

  /// Close all boxes/collections
  Future<void> closeAll();

  /// Delete all data from disk
  Future<void> deleteAll();

  /// Register a type adapter for custom objects (Hive-specific, optional for other implementations)
  void registerAdapter<T>(dynamic adapter);

  /// Check if a box is currently open
  bool isBoxOpen(String boxName);
}

/// Box/Collection interface for CRUD operations
abstract class IDatabaseBox<T> {
  /// Box/collection name
  String get name;

  /// Put a value with a key
  Future<void> put(String key, T value);

  /// Get a value by key
  Future<T?> get(String key);

  /// Delete a value by key
  Future<void> delete(String key);

  /// Get all values
  Future<List<T>> getAll();

  /// Get all keys
  Future<List<String>> getAllKeys();

  /// Clear all data in the box
  Future<void> clear();

  /// Check if key exists
  Future<bool> containsKey(String key);

  /// Get count of items
  Future<int> count();

  /// Put multiple values at once
  Future<void> putAll(Map<String, T> entries);

  /// Delete multiple keys at once
  Future<void> deleteAll(List<String> keys);

  /// Watch for changes in the box (returns stream of events when data changes)
  Stream<DatabaseEvent> watch({String? key});

  /// Close the box
  Future<void> close();
}

/// Event emitted when database data changes
class DatabaseEvent {
  final String? key;
  final dynamic value;
  final bool deleted;

  DatabaseEvent({this.key, this.value, this.deleted = false});
}
