/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'AppException: $message (Status: $statusCode)';
}

/// Server/API exceptions
class ServerException extends AppException {
  ServerException({required super.message, super.statusCode, super.data});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Network exceptions
class NetworkException extends AppException {
  NetworkException({
    super.message = 'No internet connection',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  AuthenticationException({
    super.message = 'Authentication failed',
    super.statusCode = 401,
    super.data,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Authorization exceptions
class AuthorizationException extends AppException {
  AuthorizationException({
    super.message = 'Access denied',
    super.statusCode = 403,
    super.data,
  });

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    super.message = 'Validation failed',
    super.statusCode = 400,
    super.data,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message - Errors: $errors';
    }
    return 'ValidationException: $message';
  }
}

/// Cache/Storage exceptions
class CacheException extends AppException {
  CacheException({
    super.message = 'Cache operation failed',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// WebSocket exceptions
class WebSocketException extends AppException {
  WebSocketException({
    super.message = 'WebSocket connection failed',
    super.statusCode,
    super.data,
  });

  @override
  String toString() => 'WebSocketException: $message';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({
    super.message = 'Request timed out',
    super.statusCode = 408,
    super.data,
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
    super.data,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Bad request exceptions
class BadRequestException extends AppException {
  BadRequestException({
    super.message = 'Bad request',
    super.statusCode = 400,
    super.data,
  });

  @override
  String toString() => 'BadRequestException: $message';
}
