import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lighten_up/core/network/http_client_interface.dart';
import 'package:lighten_up/core/network/dio_http_client.dart';
import 'package:lighten_up/core/network/mock_api_interceptor.dart';
import 'package:lighten_up/core/storage/secure_storage_interface.dart';
import 'package:lighten_up/core/storage/flutter_secure_storage_adapter.dart';
import 'package:lighten_up/core/storage/preferences_storage.dart';
import 'package:lighten_up/core/storage/database_interface.dart';
import 'package:lighten_up/core/storage/hive_database_adapter.dart';
import 'package:lighten_up/data/repositories/auth_repository.dart';
import 'package:lighten_up/data/repositories/auth_repository_impl.dart';

part 'core_providers.g.dart';

/// Provides singleton instance of ISecureStorage
/// Follows Adapter Pattern - depends on interface, not implementation
@Riverpod(keepAlive: true)
ISecureStorage secureStorage(Ref ref) {
  return FlutterSecureStorageAdapter();
}

/// Provides singleton instance of PreferencesStorage
@Riverpod(keepAlive: true)
PreferencesStorage preferencesStorage(Ref ref) {
  return PreferencesStorage();
}

/// Provides singleton instance of IDatabase (using Hive adapter)
/// Follows Adapter Pattern - depends on interface, not implementation
@Riverpod(keepAlive: true)
IDatabase database(Ref ref) {
  return HiveDatabaseAdapter();
}

/// Provides singleton instance of IHttpClient (using Dio adapter)
/// With mock interceptor for development (no backend required)
/// Follows Adapter Pattern - depends on interface, not implementation
@Riverpod(keepAlive: true)
IHttpClient httpClient(Ref ref) {
  // Create HTTP client with Dio adapter and mock interceptor for development
  return DioHttpClient(
    additionalInterceptors: [
      MockApiInterceptor(), // Mock API responses - remove when using real backend
    ],
  );
}

/// Provides singleton instance of AuthRepository
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final httpClient = ref.watch(httpClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthRepositoryImpl(
    httpClient: httpClient,
    secureStorage: secureStorage,
  );
}
