import 'package:dio/dio.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Mock API interceptor for development without a real backend
/// Simulates API responses for testing the app
class MockApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('🔶 Mock API Request: ${options.method} ${options.path}');

    // Check if this is a mock-able endpoint
    final mockResponse = _getMockResponse(options);

    if (mockResponse != null) {
      AppLogger.info('✅ Returning mock response');
      return handler.resolve(mockResponse);
    }

    // If no mock available, continue with real request (will fail if no backend)
    AppLogger.warning('⚠️ No mock available, attempting real request');
    return handler.next(options);
  }

  Response? _getMockResponse(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    // Mock login endpoint
    if (path.contains('auth/login') && method == 'POST') {
      return _mockLogin(options);
    }

    // Mock current user endpoint
    if (path.contains('users/me') && method == 'GET') {
      return _mockCurrentUser(options);
    }

    // Mock logout endpoint
    if (path.contains('auth/logout') && method == 'POST') {
      return _mockLogout(options);
    }

    return null;
  }

  Response _mockLogin(RequestOptions options) {
    final data = options.data as Map<String, dynamic>?;
    final email = data?['email'] as String?;
    final password = data?['password'] as String?;

    // Simple validation - accept any email/password for demo
    // In real app, you'd validate credentials
    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response(
        requestOptions: options,
        statusCode: 400,
        data: {'message': 'Email and password are required'},
      );
    }

    // Return mock successful login response
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: {
        'access_token':
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expires_in': 3600,
        'user': {
          'id': 'user_123',
          'email': email,
          'first_name': 'John',
          'last_name': 'Doe',
          'role': 'doctor',
          'status': 'online',
          'avatar_url': null,
          'phone_number': '+1234567890',
          'department': 'Cardiology',
          'title': 'Senior Physician',
          'is_active': true,
          'is_verified': true,
          'last_seen_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now()
              .subtract(const Duration(days: 365))
              .toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      },
    );
  }

  Response _mockCurrentUser(RequestOptions options) {
    // Return mock user data
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: {
        'id': 'user_123',
        'email': 'john.doe@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'role': 'doctor',
        'status': 'online',
        'avatar_url': null,
        'phone_number': '+1234567890',
        'department': 'Cardiology',
        'title': 'Senior Physician',
        'is_active': true,
        'is_verified': true,
        'last_seen_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Response _mockLogout(RequestOptions options) {
    // Return successful logout
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: {'message': 'Logged out successfully'},
    );
  }
}
