import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lighten_up/core/theme/app_theme.dart';
import 'package:lighten_up/core/widgets/app_scaffold.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';
import 'package:lighten_up/presentation/screens/alerts/alert_settings_screen.dart';
import 'package:lighten_up/presentation/screens/auth/login_screen.dart';
import 'package:lighten_up/presentation/screens/dashboard/room_dashboard_screen.dart';
import 'package:lighten_up/presentation/screens/messages/messages_screen.dart';
import 'package:lighten_up/presentation/screens/reports/reports_screen.dart';
import 'package:lighten_up/presentation/screens/settings/settings_screen.dart';
import 'package:lighten_up/presentation/screens/staff/staff_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const AppScaffold(child: RoomDashboardScreen()),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const AppScaffold(child: MessagesScreen()),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) =>
            const AppScaffold(child: AlertSettingsScreen()),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const AppScaffold(child: StaffScreen()),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const AppScaffold(child: ReportsScreen()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppScaffold(child: SettingsScreen()),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lighten Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
