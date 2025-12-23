import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/widgets/notification_dock/dock_header.dart';
import 'package:lighten_up/core/widgets/notification_dock/status_toggle.dart';
import 'package:lighten_up/core/widgets/notification_dock/alert_section.dart';
import 'package:lighten_up/core/widgets/notification_dock/dock_footer.dart';
import 'package:lighten_up/data/models/alert.dart';
import 'package:lighten_up/data/models/user.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';

/// Notification dock widget - right sidebar showing alerts and status
class NotificationDock extends ConsumerStatefulWidget {
  const NotificationDock({super.key});

  @override
  ConsumerState<NotificationDock> createState() => _NotificationDockState();
}

class _NotificationDockState extends ConsumerState<NotificationDock> {
  UserStatus selectedStatus = UserStatus.online;

  // Mock alert data - will be replaced with real data from provider
  List<Alert> get mockAlerts => [
    Alert(
      id: '1',
      title: 'Exam Room 1',
      description: 'Code Blue',
      type: AlertType.emergency,
      severity: AlertSeverity.emergency,
      status: AlertStatus.active,
      createdAt: DateTime.now().subtract(const Duration(seconds: 45)),
    ),
    Alert(
      id: '2',
      title: 'Triage 3',
      description: 'Nurse Needed',
      type: AlertType.medical,
      severity: AlertSeverity.high,
      status: AlertStatus.active,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Alert(
      id: '3',
      title: 'Exam Room 4',
      description: 'Patient Ready',
      type: AlertType.medical,
      severity: AlertSeverity.medium,
      status: AlertStatus.active,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Alert(
      id: '4',
      title: 'Hygiene 2',
      description: 'Room Available',
      type: AlertType.system,
      severity: AlertSeverity.low,
      status: AlertStatus.active,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  List<Alert> get urgentAlerts =>
      mockAlerts.where((alert) => alert.isCritical).toList();

  List<Alert> get roomStatusAlerts =>
      mockAlerts.where((alert) => !alert.isCritical).toList();

  void _handleStatusChanged(UserStatus newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });
    // TODO: Update user status via provider
  }

  void _handleAlertTap(Alert alert) {
    // TODO: Handle alert tap - show details, acknowledge, etc.
    debugPrint('Alert tapped: ${alert.id} - ${alert.title}');
  }

  void _handleMenuTap() {
    // TODO: Show options menu
    debugPrint('Menu tapped');
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Material(
      color: AppColors.backgroundDark,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border(
            left: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with logo, station info, and menu
            DockHeader(user: user, onMenuTap: _handleMenuTap),

            // User status toggle (Available/Busy/Away)
            StatusToggle(
              selectedStatus: selectedStatus,
              onStatusChanged: _handleStatusChanged,
            ),

            // Scrollable alert list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // My Alerts section (urgent/critical)
                  AlertSection(
                    title: 'MY ALERTS',
                    alerts: urgentAlerts,
                    badgeColor: AppColors.alertRed,
                    onAlertTap: _handleAlertTap,
                  ),

                  // Divider between sections
                  if (urgentAlerts.isNotEmpty && roomStatusAlerts.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),

                  // Room Status section (non-critical)
                  AlertSection(
                    title: 'ROOM STATUS',
                    alerts: roomStatusAlerts,
                    badgeColor: AppColors.primary,
                    onAlertTap: _handleAlertTap,
                  ),
                ],
              ),
            ),

            // Footer with user info and logout button
            DockFooter(user: user, onLogout: _handleLogout),
          ],
        ),
      ),
    );
  }
}
