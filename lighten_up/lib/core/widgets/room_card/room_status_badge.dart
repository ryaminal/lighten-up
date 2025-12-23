import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/room.dart';

/// Status badge widget for room header
class RoomStatusBadge extends StatelessWidget {
  final RoomStatus status;

  const RoomStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space2xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: status == RoomStatus.occupied
            ? statusInfo.color.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        statusInfo.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: statusInfo.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return _StatusInfo(color: AppColors.textSecondary, label: 'Available');
      case RoomStatus.occupied:
        return _StatusInfo(color: AppColors.alertGreen, label: 'Occupied');
      case RoomStatus.cleaning:
        return _StatusInfo(color: AppColors.alertAmber, label: 'Cleaning');
      case RoomStatus.maintenance:
        return _StatusInfo(color: AppColors.alertRed, label: 'Maintenance');
    }
  }
}

/// Helper class for status information
class _StatusInfo {
  final Color color;
  final String label;

  _StatusInfo({required this.color, required this.label});
}
