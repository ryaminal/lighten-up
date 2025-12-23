import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lighten_up/core/widgets/app_scaffold.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';
import 'package:lighten_up/presentation/screens/alerts/alert_settings_screen.dart';
import 'package:lighten_up/presentation/screens/auth/login_screen.dart';
import 'package:lighten_up/presentation/screens/dashboard/room_dashboard_screen.dart';
import 'package:lighten_up/presentation/screens/messages/messages_screen.dart';
import 'package:lighten_up/presentation/screens/reports/reports_screen.dart';
import 'package:lighten_up/presentation/screens/settings/settings_screen.dart';
import 'package:lighten_up/presentation/screens/staff/staff_screen.dart';

/// Route path constants for type-safe navigation
abstract class RoutePaths {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String messages = '/messages';
  static const String alerts = '/alerts';
  static const String staff = '/staff';
  static const String reports = '/reports';
  static const String settings = '/settings';
}

/// Router configuration provider with authentication-aware navigation
///
/// Automatically redirects unauthenticated users to login and
/// authenticated users away from login screen to dashboard.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: true,
    redirect: (context, state) => _handleAuthRedirect(
      isAuthenticated: authState.isAuthenticated,
      currentLocation: state.matchedLocation,
    ),
    routes: _buildRoutes(),
  );
});

/// Handle authentication-based redirects
///
/// Returns the path to redirect to, or null if no redirect is needed.
String? _handleAuthRedirect({
  required bool isAuthenticated,
  required String currentLocation,
}) {
  final isOnLoginPage = currentLocation == RoutePaths.login;

  // Redirect unauthenticated users to login (unless already there)
  if (!isAuthenticated && !isOnLoginPage) {
    return RoutePaths.login;
  }

  // Redirect authenticated users away from login to dashboard
  if (isAuthenticated && isOnLoginPage) {
    return RoutePaths.dashboard;
  }

  return null; // No redirect needed
}

/// Build application route configuration
List<GoRoute> _buildRoutes() {
  return [
    // Public routes (no authentication required)
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Protected routes (require authentication, use AppScaffold)
    GoRoute(
      path: RoutePaths.dashboard,
      builder: (context, state) =>
          const AppScaffold(child: RoomDashboardScreen()),
    ),
    GoRoute(
      path: RoutePaths.messages,
      builder: (context, state) => const AppScaffold(child: MessagesScreen()),
    ),
    GoRoute(
      path: RoutePaths.alerts,
      builder: (context, state) =>
          const AppScaffold(child: AlertSettingsScreen()),
    ),
    GoRoute(
      path: RoutePaths.staff,
      builder: (context, state) => const AppScaffold(child: StaffScreen()),
    ),
    GoRoute(
      path: RoutePaths.reports,
      builder: (context, state) => const AppScaffold(child: ReportsScreen()),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const AppScaffold(child: SettingsScreen()),
    ),
  ];
}
