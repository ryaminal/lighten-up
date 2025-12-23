/// Database - Local database abstraction layer
///
/// This module provides local database/NoSQL functionality following the Adapter Pattern.
/// Use IDatabase interface for all dependencies to enable easy testing and mocking.
///
/// Currently using Hive (NoSQL key-value store) but can be swapped for other NoSQL databases
/// like Isar, ObjectBox, Realm, or even cloud NoSQL like Firebase/Firestore.
///
/// Example usage:
/// ```dart
/// // For dependency injection (recommended):
/// final IDatabase db = HiveDatabaseAdapter();
/// await db.init();
/// final box = await db.openBox<MyModel>('my_collection');
/// await box.put('key1', myModel);
/// ```

library;

export 'database_interface.dart';
export 'hive_database_adapter.dart';
