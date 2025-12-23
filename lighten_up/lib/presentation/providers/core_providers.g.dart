// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStorageHash() => r'bdd778205a66e2a9aaae41ad6c85020c45d3b947';

/// Provides singleton instance of ISecureStorage
/// Follows Adapter Pattern - depends on interface, not implementation
///
/// Copied from [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<ISecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<ISecureStorage>;
String _$preferencesStorageHash() =>
    r'54ec9105ec7b797620d16be1d5547026eec509de';

/// Provides singleton instance of PreferencesStorage
///
/// Copied from [preferencesStorage].
@ProviderFor(preferencesStorage)
final preferencesStorageProvider = Provider<PreferencesStorage>.internal(
  preferencesStorage,
  name: r'preferencesStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferencesStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreferencesStorageRef = ProviderRef<PreferencesStorage>;
String _$databaseHash() => r'2215f016986d832968b21a226c6d55dd6d3a3137';

/// Provides singleton instance of IDatabase (using Hive adapter)
/// Follows Adapter Pattern - depends on interface, not implementation
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = Provider<IDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<IDatabase>;
String _$httpClientHash() => r'236c542c16f371606a6d9f8663b2553f89991ea0';

/// Provides singleton instance of IHttpClient (using Dio adapter)
/// With mock interceptor for development (no backend required)
/// Follows Adapter Pattern - depends on interface, not implementation
///
/// Copied from [httpClient].
@ProviderFor(httpClient)
final httpClientProvider = Provider<IHttpClient>.internal(
  httpClient,
  name: r'httpClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$httpClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HttpClientRef = ProviderRef<IHttpClient>;
String _$authRepositoryHash() => r'b1687964d500954c888036330f3516c33859eb0f';

/// Provides singleton instance of AuthRepository
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
