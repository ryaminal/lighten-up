import 'package:dio/dio.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/network/api_endpoints.dart';
import 'package:lighten_up/core/network/api_interceptor.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// HTTP client wrapper using Dio
/// Handles all API communication with proper error handling
class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  ApiClient({
    String? baseUrl,
    String? accessToken,
    List<Interceptor>? additionalInterceptors,
  }) : _accessToken = accessToken {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor(getAccessToken: () => _accessToken));

    if (additionalInterceptors != null) {
      _dio.interceptors.addAll(additionalInterceptors);
    }
  }

  /// Update the access token
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Get the current access token
  String? get accessToken => _accessToken;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with multipart/form-data
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileField = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  Exception _handleError(DioException error) {
    AppLogger.error('DioException: ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timed out. Please try again.',
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return BadRequestException(
              message: _extractErrorMessage(data) ?? 'Invalid request',
              statusCode: statusCode,
              data: data,
            );
          case 401:
            return AuthenticationException(
              message: _extractErrorMessage(data) ?? 'Authentication failed',
              statusCode: statusCode,
              data: data,
            );
          case 403:
            return AuthorizationException(
              message: _extractErrorMessage(data) ?? 'Access denied',
              statusCode: statusCode,
              data: data,
            );
          case 404:
            return NotFoundException(
              message: _extractErrorMessage(data) ?? 'Resource not found',
              statusCode: statusCode,
              data: data,
            );
          case 422:
            return ValidationException(
              message: _extractErrorMessage(data) ?? 'Validation failed',
              statusCode: statusCode,
              data: data,
              errors: _extractValidationErrors(data),
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              message: _extractErrorMessage(data) ?? 'Server error occurred',
              statusCode: statusCode,
              data: data,
            );
          default:
            return ServerException(
              message: _extractErrorMessage(data) ?? 'An error occurred',
              statusCode: statusCode,
              data: data,
            );
        }

      case DioExceptionType.cancel:
        return ServerException(
          message: 'Request was cancelled',
          data: error.response?.data,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network.',
          data: error.response?.data,
        );

      case DioExceptionType.badCertificate:
        return ServerException(
          message: 'Certificate verification failed',
          data: error.response?.data,
        );

      case DioExceptionType.unknown:
        return ServerException(
          message: error.message ?? 'An unexpected error occurred',
          data: error.response?.data,
        );
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }
    if (data is String) {
      return data;
    }
    return null;
  }

  /// Extract validation errors from response data
  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data == null || data is! Map) return null;

    final errors = data['errors'];
    if (errors == null || errors is! Map) return null;

    final Map<String, List<String>> validationErrors = {};

    errors.forEach((key, value) {
      if (value is List) {
        validationErrors[key as String] = value.cast<String>();
      } else if (value is String) {
        validationErrors[key as String] = [value];
      }
    });

    return validationErrors.isNotEmpty ? validationErrors : null;
  }

  /// Close the client and release resources
  void close() {
    _dio.close();
  }
}
