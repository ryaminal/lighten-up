import 'package:flutter/material.dart';
import 'package:lighten_up/core/widgets/navigation_sidebar.dart';
import 'package:lighten_up/core/widgets/notification_dock.dart';

/// Main app scaffold with navigation sidebar and notification dock
/// Wraps all authenticated screens with consistent layout
class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left navigation sidebar
        const NavigationSidebar(),

        // Main content area
        Expanded(child: child),

        // Right notification dock
        const NotificationDock(),
      ],
    );
  }
}
