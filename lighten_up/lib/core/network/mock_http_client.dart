import 'package:dio/dio.dart';
import 'package:lighten_up/core/network/http_client_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';

/// Mock HTTP Client implementing IHttpClient interface
/// Used for testing and development without a real backend
/// Provides realistic mock responses for all API endpoints
class MockHttpClient implements IHttpClient {
  String? _accessToken;

  @override
  String? get accessToken => _accessToken;

  @override
  void setAccessToken(String? token) {
    _accessToken = token;
    AppLogger.debug('MockHttpClient: Access token set');
  }

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock GET: $path');
    await _simulateNetworkDelay();

    final response = _getMockResponse(
      'GET',
      path,
      queryParameters: queryParameters,
    );
    return HttpResponse<T>(
      data: response['data'] as T,
      statusCode: response['statusCode'] as int,
      headers: {},
    );
  }

  @override
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock POST: $path');
    await _simulateNetworkDelay();

    final response = _getMockResponse('POST', path, data: data);
    return HttpResponse<T>(
      data: response['data'] as T,
      statusCode: response['statusCode'] as int,
      headers: {},
    );
  }

  @override
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock PUT: $path');
    await _simulateNetworkDelay();

    final response = _getMockResponse('PUT', path, data: data);
    return HttpResponse<T>(
      data: response['data'] as T,
      statusCode: response['statusCode'] as int,
      headers: {},
    );
  }

  @override
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock PATCH: $path');
    await _simulateNetworkDelay();

    final response = _getMockResponse('PATCH', path, data: data);
    return HttpResponse<T>(
      data: response['data'] as T,
      statusCode: response['statusCode'] as int,
      headers: {},
    );
  }

  @override
  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock DELETE: $path');
    await _simulateNetworkDelay();

    final response = _getMockResponse('DELETE', path, data: data);
    return HttpResponse<T>(
      data: response['data'] as T,
      statusCode: response['statusCode'] as int,
      headers: {},
    );
  }

  @override
  Future<HttpResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileField = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    AppLogger.info('🔶 Mock UPLOAD: $path');
    await _simulateNetworkDelay(milliseconds: 1000); // Longer delay for uploads

    return HttpResponse<T>(
      data:
          {
                'message': 'File uploaded successfully',
                'file_url': 'https://example.com/uploads/mock_file.jpg',
                'file_id': 'file_${DateTime.now().millisecondsSinceEpoch}',
              }
              as T,
      statusCode: 200,
      headers: {},
    );
  }

  @override
  Future<HttpResponse> downloadFile(
    String urlPath,
    String savePath, {
    CancelToken? cancelToken,
  }) async {
    AppLogger.info('🔶 Mock DOWNLOAD: $urlPath');
    await _simulateNetworkDelay(
      milliseconds: 1000,
    ); // Longer delay for downloads

    return const HttpResponse(
      data: {'message': 'File downloaded successfully'},
      statusCode: 200,
      headers: {},
    );
  }

  @override
  void close() {
    AppLogger.debug('MockHttpClient: Closed');
  }

  /// Simulate network delay for realistic testing
  Future<void> _simulateNetworkDelay({int milliseconds = 300}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Get mock response based on endpoint
  Map<String, dynamic> _getMockResponse(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    // Authentication endpoints
    if (path.contains('auth/login') && method == 'POST') {
      return _mockLogin(data);
    }
    if (path.contains('auth/logout') && method == 'POST') {
      return _mockLogout();
    }
    if (path.contains('auth/refresh') && method == 'POST') {
      return _mockRefreshToken();
    }
    if (path.contains('auth/verify-pin') && method == 'POST') {
      return _mockVerifyPin(data);
    }

    // User endpoints
    if (path.contains('users/me') && method == 'GET') {
      return _mockCurrentUser();
    }
    if (path.contains('users/') && method == 'PUT') {
      return _mockUpdateUser(data);
    }
    if (path.contains('users') && method == 'GET') {
      return _mockGetUsers(queryParameters);
    }

    // Messages endpoints
    if (path.contains('messages') && method == 'GET') {
      return _mockGetMessages(queryParameters);
    }
    if (path.contains('messages') && method == 'POST') {
      return _mockSendMessage(data);
    }

    // Notifications endpoints
    if (path.contains('notifications') && method == 'GET') {
      return _mockGetNotifications(queryParameters);
    }

    // Alerts endpoints
    if (path.contains('alerts') && method == 'GET') {
      return _mockGetAlerts(queryParameters);
    }
    if (path.contains('alerts') && method == 'POST') {
      return _mockCreateAlert(data);
    }

    // Patients endpoints
    if (path.contains('patients') && method == 'GET') {
      return _mockGetPatients(queryParameters);
    }

    // Rooms endpoints
    if (path.contains('rooms') && method == 'GET') {
      return _mockGetRooms(queryParameters);
    }

    // Default 404 response
    return {
      'statusCode': 404,
      'data': {'message': 'Mock endpoint not implemented: $method $path'},
    };
  }

  // ========== Mock Endpoint Implementations ==========

  Map<String, dynamic> _mockLogin(dynamic data) {
    final requestData = data as Map<String, dynamic>?;
    final email = requestData?['email'] as String?;
    final password = requestData?['password'] as String?;

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return {
        'statusCode': 400,
        'data': {'message': 'Email and password are required'},
      };
    }

    final now = DateTime.now();
    return {
      'statusCode': 200,
      'data': {
        'access_token': 'mock_access_token_${now.millisecondsSinceEpoch}',
        'refresh_token': 'mock_refresh_token_${now.millisecondsSinceEpoch}',
        'expires_in': 3600,
        'user': _getMockUser(email: email),
      },
    };
  }

  Map<String, dynamic> _mockLogout() {
    return {
      'statusCode': 200,
      'data': {'message': 'Logged out successfully'},
    };
  }

  Map<String, dynamic> _mockRefreshToken() {
    final now = DateTime.now();
    return {
      'statusCode': 200,
      'data': {
        'access_token': 'mock_access_token_${now.millisecondsSinceEpoch}',
        'refresh_token': 'mock_refresh_token_${now.millisecondsSinceEpoch}',
        'user': _getMockUser(),
        'expires_in': 3600,
      },
    };
  }

  Map<String, dynamic> _mockVerifyPin(dynamic data) {
    final requestData = data as Map<String, dynamic>?;
    final pin = requestData?['pin'] as String?;

    // Accept any 4-digit PIN for demo
    final isValid = pin != null && pin.length == 4 && int.tryParse(pin) != null;

    return {
      'statusCode': 200,
      'data': {'valid': isValid},
    };
  }

  Map<String, dynamic> _mockCurrentUser() {
    return {'statusCode': 200, 'data': _getMockUser()};
  }

  Map<String, dynamic> _mockUpdateUser(dynamic data) {
    final requestData = data as Map<String, dynamic>?;
    return {
      'statusCode': 200,
      'data': {..._getMockUser(), ...?requestData},
    };
  }

  Map<String, dynamic> _mockGetUsers(Map<String, dynamic>? queryParams) {
    return {
      'statusCode': 200,
      'data': {
        'users': List.generate(5, (i) => _getMockUser(id: 'user_$i')),
        'total': 5,
        'page': 1,
        'per_page': 10,
      },
    };
  }

  Map<String, dynamic> _mockGetMessages(Map<String, dynamic>? queryParams) {
    return {
      'statusCode': 200,
      'data': {
        'messages': List.generate(
          10,
          (i) => {
            'id': 'msg_$i',
            'content': 'Mock message $i',
            'sender_id': 'user_${i % 3}',
            'created_at': DateTime.now()
                .subtract(Duration(hours: i))
                .toIso8601String(),
          },
        ),
        'total': 10,
      },
    };
  }

  Map<String, dynamic> _mockSendMessage(dynamic data) {
    return {
      'statusCode': 201,
      'data': {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'content': (data as Map<String, dynamic>?)?['content'],
        'created_at': DateTime.now().toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _mockGetNotifications(
    Map<String, dynamic>? queryParams,
  ) {
    return {
      'statusCode': 200,
      'data': {'notifications': [], 'total': 0},
    };
  }

  Map<String, dynamic> _mockGetAlerts(Map<String, dynamic>? queryParams) {
    return {
      'statusCode': 200,
      'data': {'alerts': [], 'total': 0},
    };
  }

  Map<String, dynamic> _mockCreateAlert(dynamic data) {
    return {
      'statusCode': 201,
      'data': {
        'id': 'alert_${DateTime.now().millisecondsSinceEpoch}',
        ...(data as Map<String, dynamic>? ?? {}),
        'created_at': DateTime.now().toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _mockGetPatients(Map<String, dynamic>? queryParams) {
    return {
      'statusCode': 200,
      'data': {'patients': [], 'total': 0},
    };
  }

  Map<String, dynamic> _mockGetRooms(Map<String, dynamic>? queryParams) {
    return {
      'statusCode': 200,
      'data': {'rooms': [], 'total': 0},
    };
  }

  /// Generate mock user data
  Map<String, dynamic> _getMockUser({String? id, String? email}) {
    final now = DateTime.now();
    return {
      'id': id ?? 'user_123',
      'email': email ?? 'john.doe@example.com',
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
      'last_seen_at': now.toIso8601String(),
      'created_at': now.subtract(const Duration(days: 365)).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }
}
