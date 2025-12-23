import 'package:dio/dio.dart';

/// HTTP client interface for making API requests
/// Follows Adapter Pattern - abstracts away concrete HTTP client implementation
/// This allows easy swapping of HTTP libraries (Dio, http, etc.) without changing consuming code
abstract class IHttpClient {
  /// Set access token for authentication
  void setAccessToken(String? token);

  /// Get current access token
  String? get accessToken;

  /// GET request
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  /// POST request
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  /// PUT request
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  /// PATCH request
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  /// DELETE request
  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  /// Upload file
  Future<HttpResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileField = 'file',
    Map<String, dynamic>? additionalData,
  });

  /// Download file
  Future<HttpResponse> downloadFile(
    String urlPath,
    String savePath, {
    CancelToken? cancelToken,
  });

  /// Close client and release resources
  void close();
}

/// HTTP response wrapper - abstracts away Dio's Response type
/// Allows consuming code to work with responses without depending on Dio
class HttpResponse<T> {
  final T? data;
  final int? statusCode;
  final String? statusMessage;
  final Map<String, dynamic>? headers;

  const HttpResponse({
    this.data,
    this.statusCode,
    this.statusMessage,
    this.headers,
  });

  /// Create from Dio Response
  factory HttpResponse.fromDioResponse(Response<T> response) {
    return HttpResponse<T>(
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }
}
