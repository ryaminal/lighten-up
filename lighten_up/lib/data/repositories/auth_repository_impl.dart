import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/network/http_client_interface.dart';
import 'package:lighten_up/core/network/api_endpoints.dart';
import 'package:lighten_up/core/storage/secure_storage_interface.dart';
import 'package:lighten_up/core/utils/logger.dart';
import 'package:lighten_up/data/models/user.dart';
import 'package:lighten_up/data/repositories/auth_repository.dart';

/// Implementation of AuthRepository using IHttpClient and ISecureStorage
/// Follows Adapter Pattern - depends on interfaces, not concrete implementations
class AuthRepositoryImpl implements AuthRepository {
  final IHttpClient _httpClient;
  final ISecureStorage _secureStorage;

  AuthRepositoryImpl({
    required IHttpClient httpClient,
    required ISecureStorage secureStorage,
  }) : _httpClient = httpClient,
       _secureStorage = secureStorage;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      AppLogger.info('Attempting login for: ${request.email}');

      final response = await _httpClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store tokens in secure storage
      await _secureStorage.saveAccessToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
      await _secureStorage.saveUserId(authResponse.user.id);

      // Update API client with new access token
      _httpClient.setAccessToken(authResponse.accessToken);

      AppLogger.info('Login successful for user: ${authResponse.user.id}');

      return authResponse;
    } on ServerException catch (e) {
      AppLogger.error('Login failed: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected login error: $e');
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user');

      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken != null) {
        try {
          // Attempt to logout on server
          await _httpClient.post(ApiEndpoints.logout);
        } catch (e) {
          // Continue with local logout even if server logout fails
          AppLogger.warning(
            'Server logout failed, continuing with local logout: $e',
          );
        }
      }

      // Clear local storage
      await _secureStorage.deleteAccessToken();
      await _secureStorage.deleteRefreshToken();
      await _secureStorage.deleteUserId();

      // Clear API client token
      _httpClient.setAccessToken(null);

      AppLogger.info('Logout complete');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<AuthResponse> refreshToken() async {
    try {
      AppLogger.info('Refreshing access token');

      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthenticationException(message: 'No refresh token available');
      }

      final response = await _httpClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store new tokens
      await _secureStorage.saveAccessToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);

      // Update API client with new access token
      _httpClient.setAccessToken(authResponse.accessToken);

      AppLogger.info('Token refresh successful');

      return authResponse;
    } on ServerException catch (e) {
      AppLogger.error('Token refresh failed: ${e.message}');
      // Clear tokens on refresh failure
      await _secureStorage.deleteAccessToken();
      await _secureStorage.deleteRefreshToken();
      _httpClient.setAccessToken(null);
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected token refresh error: $e');
      throw ServerException(message: 'Token refresh failed: $e');
    }
  }

  @override
  Future<bool> verifyPin(PinRequest request) async {
    try {
      AppLogger.info('Verifying PIN for user: ${request.userId}');

      final response = await _httpClient.post(
        ApiEndpoints.verifyPin,
        data: request.toJson(),
      );

      final isValid = response.data['valid'] as bool? ?? false;

      AppLogger.info('PIN verification result: $isValid');

      return isValid;
    } on ServerException catch (e) {
      AppLogger.error('PIN verification failed: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected PIN verification error: $e');
      throw ServerException(message: 'PIN verification failed: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      AppLogger.info('Fetching current user');

      final response = await _httpClient.get(ApiEndpoints.currentUser);

      final user = User.fromJson(response.data);

      AppLogger.info('Current user fetched: ${user.id}');

      return user;
    } on ServerException catch (e) {
      AppLogger.error('Get current user failed: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected get current user error: $e');
      throw ServerException(message: 'Failed to get current user: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        return false;
      }

      // Check if token is still valid by trying to fetch current user
      try {
        await getCurrentUser();
        return true;
      } on AuthenticationException {
        // Token is invalid or expired
        return false;
      }
    } catch (e) {
      AppLogger.error('Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<User> updateProfile(User user) async {
    try {
      AppLogger.info('Updating user profile: ${user.id}');

      final response = await _httpClient.put(
        '${ApiEndpoints.users}/${user.id}',
        data: user.toJson(),
      );

      final updatedUser = User.fromJson(response.data);

      AppLogger.info('User profile updated: ${updatedUser.id}');

      return updatedUser;
    } on ServerException catch (e) {
      AppLogger.error('Update profile failed: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected update profile error: $e');
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Changing password');

      await _httpClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      AppLogger.info('Password changed successfully');
    } on ServerException catch (e) {
      AppLogger.error('Change password failed: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected change password error: $e');
      throw ServerException(message: 'Failed to change password: $e');
    }
  }
}
