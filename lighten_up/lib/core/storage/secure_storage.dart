/// Secure Storage - Secure data persistence abstraction layer
///
/// This module provides secure storage functionality following the Adapter Pattern.
/// Use ISecureStorage interface for all dependencies to enable easy testing and mocking.
///
/// Example usage:
/// ```dart
/// // For dependency injection (recommended):
/// final ISecureStorage storage = FlutterSecureStorageAdapter();
/// ```

library;

export 'secure_storage_interface.dart';
export 'flutter_secure_storage_adapter.dart';
