import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
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

  // Mock alert data - will be replaced with real data
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
            left: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with logo and station info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lighten Up',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Station: ${user?.department ?? 'Main'}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      // TODO: Show options menu
                    },
                  ),
                ],
              ),
            ),

            // User status toggle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMd,
                vertical: AppDimensions.spaceSm,
              ),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _StatusButton(
                      label: 'Avail',
                      status: UserStatus.online,
                      isSelected: selectedStatus == UserStatus.online,
                      onTap: () {
                        setState(() => selectedStatus = UserStatus.online);
                      },
                    ),
                    _StatusButton(
                      label: 'Busy',
                      status: UserStatus.busy,
                      isSelected: selectedStatus == UserStatus.busy,
                      onTap: () {
                        setState(() => selectedStatus = UserStatus.busy);
                      },
                    ),
                    _StatusButton(
                      label: 'Away',
                      status: UserStatus.away,
                      isSelected: selectedStatus == UserStatus.away,
                      onTap: () {
                        setState(() => selectedStatus = UserStatus.away);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable alert list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMd,
                  vertical: AppDimensions.spaceSm,
                ),
                children: [
                  // My Alerts section (urgent)
                  if (urgentAlerts.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MY ALERTS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Text(
                            '${urgentAlerts.length} URGENT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.alertRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    ...urgentAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spaceSm,
                        ),
                        child: _AlertCard(alert: alert),
                      ),
                    ),
                  ],

                  // Room Status section
                  if (roomStatusAlerts.isNotEmpty) ...[
                    if (urgentAlerts.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceMd,
                        ),
                        height: 1,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    Text(
                      'ROOM STATUS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    ...roomStatusAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spaceSm,
                        ),
                        child: _AlertCard(alert: alert),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer with user info and logout
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.initials ?? '??',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.roleDisplayName ?? 'Role',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    color: AppColors.textSecondary,
                    tooltip: 'Logout',
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status toggle button
class _StatusButton extends StatelessWidget {
  final String label;
  final UserStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alert card widget
class _AlertCard extends StatelessWidget {
  final Alert alert;

  const _AlertCard({required this.alert});

  Color _getBorderColor() {
    switch (alert.severity) {
      case AlertSeverity.emergency:
        return AppColors.alertRed;
      case AlertSeverity.critical:
        return AppColors.alertRed;
      case AlertSeverity.high:
        return AppColors.alertAmber;
      case AlertSeverity.medium:
        return AppColors.alertGreen;
      case AlertSeverity.low:
        return AppColors.alertBlue;
    }
  }

  Color _getIconBackgroundColor() {
    return _getBorderColor().withOpacity(alert.isCritical ? 0.2 : 0.1);
  }

  IconData _getIcon() {
    switch (alert.type) {
      case AlertType.emergency:
        return Icons.emergency;
      case AlertType.medical:
        return Icons.medical_services;
      case AlertType.medication:
        return Icons.medication;
      case AlertType.vitals:
        return Icons.favorite;
      case AlertType.appointment:
        return Icons.calendar_today;
      case AlertType.system:
        return Icons.check_circle;
      case AlertType.security:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    final iconBgColor = _getIconBackgroundColor();
    final shouldAnimate = alert.isCritical;

    return InkWell(
      onTap: () {
        // TODO: Handle alert tap
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceSm),
        decoration: BoxDecoration(
          color: alert.severity == AlertSeverity.emergency
              ? borderColor.withOpacity(0.15)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: alert.severity == AlertSeverity.emergency
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), color: borderColor, size: 20),
            ),
            const SizedBox(width: AppDimensions.spaceSm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    alert.description,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: borderColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Timer
            Text(
              alert.timeAgo,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
