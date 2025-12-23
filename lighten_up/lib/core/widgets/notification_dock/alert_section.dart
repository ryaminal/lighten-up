import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert.dart';

/// Alert section widget with header and alert list
class AlertSection extends StatelessWidget {
  final String title;
  final List<Alert> alerts;
  final Color? badgeColor;
  final void Function(Alert) onAlertTap;

  const AlertSection({
    super.key,
    required this.title,
    required this.alerts,
    this.badgeColor,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                '${alerts.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: badgeColor ?? AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        ...alerts.map(
          (alert) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
            child: AlertCard(alert: alert, onTap: () => onAlertTap(alert)),
          ),
        ),
      ],
    );
  }
}

/// Alert card widget
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const AlertCard({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color alertColor;
    IconData alertIcon;

    switch (alert.severity) {
      case AlertSeverity.emergency:
        alertColor = AppColors.alertRed;
        alertIcon = Icons.warning;
        break;
      case AlertSeverity.critical:
        alertColor = AppColors.alertOrange;
        alertIcon = Icons.crisis_alert;
        break;
      case AlertSeverity.high:
        alertColor = AppColors.alertOrange;
        alertIcon = Icons.error_outline;
        break;
      case AlertSeverity.medium:
        alertColor = AppColors.primary;
        alertIcon = Icons.info_outline;
        break;
      case AlertSeverity.low:
        alertColor = AppColors.alertGreen;
        alertIcon = Icons.notifications_outlined;
        break;
    }

    final duration = DateTime.now().difference(alert.createdAt);
    final minutes = duration.inMinutes;
    final timeText = minutes < 1
        ? '${duration.inSeconds}s ago'
        : minutes < 60
        ? '${minutes}m ago'
        : '${duration.inHours}h ago';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: alertColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(alertIcon, color: alertColor, size: 18),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    alert.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Timer
            Text(
              timeText,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
