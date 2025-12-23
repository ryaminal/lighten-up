/// Database interface - Abstraction for NoSQL key-value storage.
/// Depend on this interface, not concrete implementations.
///
/// This interface defines the contract for interacting with a NoSQL database.
/// All infrastructure dependencies must use this interface to ensure testability,
/// flexibility, and compliance with the Adapter Pattern.
abstract class IDatabase {
  /// Initializes the database.
  ///
  /// Must be called before any other operations.
  Future<void> init();

  /// Closes and disposes the database.
  ///
  /// Releases all resources associated with the database.
  Future<void> close();

  /// Opens a typed box (collection) for a specific data type [T].
  ///
  /// [name] is the unique identifier for the box.
  /// Returns an [IDatabaseBox<T>] for performing operations on the box.
  Future<IDatabaseBox<T>> openBox<T>(String name);

  /// Deletes a box and all its data.
  ///
  /// [name] is the unique identifier for the box to delete.
  Future<void> deleteBox(String name);

  /// Checks if a box exists.
  ///
  /// [name] is the unique identifier for the box.
  /// Returns true if the box exists, false otherwise.
  Future<bool> boxExists(String name);

  /// Clears all data from all boxes in the database.
  Future<void> clearAll();
}

/// Typed box interface for storing specific data types.
///
/// This interface defines the contract for interacting with a single box (collection)
/// within the database. All operations are asynchronous and type-safe.
abstract class IDatabaseBox<T> {
  /// Gets the value associated with [key].
  ///
  /// Returns the value of type [T] if found, or null if the key does not exist.
  Future<T?> get(String key);

  /// Puts a key-value pair into the box.
  ///
  /// [key] is the unique identifier for the value.
  /// [value] is the data to store.
  Future<void> put(String key, T value);

  /// Deletes the value associated with [key].
  Future<void> delete(String key);

  /// Gets all values stored in the box.
  ///
  /// Returns a list of all values of type [T].
  Future<List<T>> getAll();

  /// Gets all keys stored in the box.
  ///
  /// Returns a list of all keys as strings.
  Future<List<String>> getAllKeys();

  /// Checks if [key] exists in the box.
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> containsKey(String key);

  /// Clears all data in this box.
  Future<void> clear();

  /// Gets the number of entries in the box.
  ///
  /// Returns the count of key-value pairs.
  Future<int> length();

  /// Closes this box and releases resources.
  Future<void> close();
}
