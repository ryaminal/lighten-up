/// API Client - HTTP client abstraction layer
///
/// This module provides HTTP client functionality following the Adapter Pattern.
/// Use IHttpClient interface for all dependencies to enable easy testing and mocking.
///
/// Example usage:
/// ```dart
/// // For dependency injection (recommended):
/// final IHttpClient httpClient = DioHttpClient(baseUrl: 'https://api.example.com');
///
/// // For backward compatibility:
/// final DioHttpClient apiClient = DioHttpClient(baseUrl: 'https://api.example.com');
/// ```

library;

export 'http_client_interface.dart';
export 'dio_http_client.dart';
