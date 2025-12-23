import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Uses Equatable for value equality
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  const Failure({required this.message, this.statusCode, this.errorData});

  @override
  List<Object?> get props => [message, statusCode, errorData];
}

/// Server/API related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.errorData,
  });
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'No internet connection. Please check your network settings.',
    super.statusCode,
    super.errorData,
  });
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed. Please login again.',
    super.statusCode,
    super.errorData,
  });
}

/// Authorization failures (permission denied)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.errorData,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode = 400,
    super.errorData,
  });
}

/// Cache/Storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.statusCode,
    super.errorData,
  });
}

/// WebSocket connection failures
class WebSocketFailure extends Failure {
  const WebSocketFailure({
    super.message = 'WebSocket connection failed.',
    super.statusCode,
    super.errorData,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
    super.statusCode = 408,
    super.errorData,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Requested resource not found.',
    super.statusCode = 404,
    super.errorData,
  });
}

/// Bad request failures
class BadRequestFailure extends Failure {
  const BadRequestFailure({
    super.message = 'Invalid request.',
    super.statusCode = 400,
    super.errorData,
  });
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.errorData,
  });
}
