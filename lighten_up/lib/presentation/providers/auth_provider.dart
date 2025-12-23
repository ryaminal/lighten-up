import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lighten_up/core/error/exceptions.dart';
import 'package:lighten_up/core/utils/logger.dart';
import 'package:lighten_up/data/models/user.dart';
import 'package:lighten_up/data/repositories/auth_repository.dart';
import 'package:lighten_up/presentation/providers/core_providers.dart';

part 'auth_provider.g.dart';

/// Auth state that holds current user and authentication status
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth notifier that manages authentication state
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    // Check authentication status on initialization
    _checkAuthStatus();

    return const AuthState(isLoading: true);
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await _repository.isAuthenticated();

      if (isAuth) {
        final user = await _repository.getCurrentUser();
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      } else {
        state = const AuthState(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      AppLogger.error('Error checking auth status: $e');
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Attempting login for: $email');

      final request = LoginRequest(email: email, password: password);

      final response = await _repository.login(request);

      state = AuthState(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Login successful');
    } on AuthenticationException catch (e) {
      AppLogger.error('Login failed: ${e.message}');
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } on ValidationException catch (e) {
      AppLogger.error('Login validation failed: ${e.message}');
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } on NetworkException catch (e) {
      AppLogger.error('Login network error: ${e.message}');
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected login error: $e');
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Logging out user');

      await _repository.logout();

      state = const AuthState(isAuthenticated: false, isLoading: false);

      AppLogger.info('Logout successful');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      // Still clear state even if server logout fails
      state = const AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      AppLogger.error('Error refreshing user: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile(User user) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await _repository.updateProfile(user);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile',
      );
      rethrow;
    }
  }

  /// Verify PIN for privacy lock
  Future<bool> verifyPin(String pin) async {
    if (state.user == null) return false;

    try {
      final request = PinRequest(userId: state.user!.id, pin: pin);
      return await _repository.verifyPin(request);
    } catch (e) {
      AppLogger.error('Error verifying PIN: $e');
      return false;
    }
  }
}
