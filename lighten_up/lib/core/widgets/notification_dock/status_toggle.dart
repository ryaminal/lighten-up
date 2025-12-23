import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/data/models/user.dart';

/// User status toggle bar with Available/Busy/Away options
class StatusToggle extends StatelessWidget {
  final UserStatus selectedStatus;
  final ValueChanged<UserStatus> onStatusChanged;

  const StatusToggle({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _StatusButton(
              label: 'Avail',
              status: UserStatus.online,
              isSelected: selectedStatus == UserStatus.online,
              onTap: () => onStatusChanged(UserStatus.online),
            ),
            _StatusButton(
              label: 'Busy',
              status: UserStatus.busy,
              isSelected: selectedStatus == UserStatus.busy,
              onTap: () => onStatusChanged(UserStatus.busy),
            ),
            _StatusButton(
              label: 'Away',
              status: UserStatus.away,
              isSelected: selectedStatus == UserStatus.away,
              onTap: () => onStatusChanged(UserStatus.away),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual status button
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
    Color statusColor;
    switch (status) {
      case UserStatus.online:
        statusColor = AppColors.alertGreen;
        break;
      case UserStatus.busy:
        statusColor = AppColors.alertOrange;
        break;
      case UserStatus.away:
        statusColor = AppColors.alertRed;
        break;
      case UserStatus.offline:
        statusColor = AppColors.textSecondary;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? statusColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? statusColor : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
