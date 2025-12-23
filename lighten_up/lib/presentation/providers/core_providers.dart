import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lighten_up/core/network/api_client.dart';
import 'package:lighten_up/core/storage/secure_storage.dart';
import 'package:lighten_up/core/storage/preferences_storage.dart';
import 'package:lighten_up/core/storage/database_helper.dart';
import 'package:lighten_up/data/repositories/auth_repository.dart';
import 'package:lighten_up/data/repositories/auth_repository_impl.dart';

part 'core_providers.g.dart';

/// Provides singleton instance of SecureStorage
@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) {
  return SecureStorage();
}

/// Provides singleton instance of PreferencesStorage
@Riverpod(keepAlive: true)
PreferencesStorage preferencesStorage(Ref ref) {
  return PreferencesStorage();
}

/// Provides singleton instance of DatabaseHelper
@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper();
}

/// Provides singleton instance of ApiClient
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

/// Provides singleton instance of AuthRepository
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthRepositoryImpl(apiClient: apiClient, secureStorage: secureStorage);
}
