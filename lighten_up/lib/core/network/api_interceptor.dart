import 'package:dio/dio.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Interceptor for logging and modifying HTTP requests and responses
class ApiInterceptor extends Interceptor {
  final String? Function()? getAccessToken;

  ApiInterceptor({this.getAccessToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    final token = getAccessToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    // Log request
    AppLogger.info('REQUEST[${options.method}] => PATH: ${options.path}');
    AppLogger.debug('Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.debug('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('Query Parameters: ${options.queryParameters}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response
    AppLogger.info(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    AppLogger.debug('Response Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    AppLogger.error('Error Message: ${err.message}');
    if (err.response != null) {
      AppLogger.error('Error Data: ${err.response?.data}');
    }

    super.onError(err, handler);
  }
}

/// Interceptor for handling token refresh and retry logic
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Future<String?> Function() refreshToken;
  final void Function(String token) saveToken;

  RetryInterceptor({
    required this.dio,
    required this.refreshToken,
    required this.saveToken,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized errors
    if (err.response?.statusCode == 401) {
      try {
        AppLogger.info('Token expired, attempting to refresh...');

        // Try to refresh the token
        final newToken = await refreshToken();

        if (newToken != null && newToken.isNotEmpty) {
          // Save the new token
          saveToken(newToken);

          // Retry the original request with the new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          AppLogger.info('Token refreshed successfully, retrying request...');

          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } else {
          AppLogger.error('Failed to refresh token');
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.error('Error during token refresh: $e');
        return handler.next(err);
      }
    }

    super.onError(err, handler);
  }
}
