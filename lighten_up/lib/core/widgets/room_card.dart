import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/room.dart';

/// Room card widget displaying room status and alert lights
class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final Function(RoomLight)? onLightTap;

  const RoomCard({super.key, required this.room, this.onTap, this.onLightTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with room name and status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceSm,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF233648),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLg),
                topRight: Radius.circular(AppDimensions.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFF2d4256), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    room.displayLabel,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: room.status),
              ],
            ),
          ),

          // Lights list - use Expanded to allow scrolling if needed
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              child: Column(
                children: room.lights.map((light) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.space2xs,
                    ),
                    child: _LightButton(
                      light: light,
                      onTap: onLightTap != null
                          ? () => onLightTap!(light)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge for room header
class _StatusBadge extends StatelessWidget {
  final RoomStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case RoomStatus.available:
        color = AppColors.textSecondary;
        label = 'Available';
        break;
      case RoomStatus.occupied:
        color = AppColors.alertGreen;
        label = 'Occupied';
        break;
      case RoomStatus.cleaning:
        color = AppColors.alertAmber;
        label = 'Cleaning';
        break;
      case RoomStatus.maintenance:
        color = AppColors.alertRed;
        label = 'Maintenance';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space2xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: status == RoomStatus.occupied
            ? color.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Light button widget
class _LightButton extends StatelessWidget {
  final RoomLight light;
  final VoidCallback? onTap;

  const _LightButton({required this.light, this.onTap});

  Color _getLightColor() {
    if (!light.isActive) {
      return const Color(0xFF111a22); // Inactive background
    }

    switch (light.priority) {
      case LightPriority.emergency:
        return AppColors.alertRed;
      case LightPriority.urgent:
        return const Color(0xFFDC2626); // Dark red
      case LightPriority.normal:
        return AppColors.alertGreen;
    }
  }

  Color _getBorderColor() {
    if (!light.isActive) {
      return const Color(0xFF2d4256);
    }

    switch (light.priority) {
      case LightPriority.emergency:
        return AppColors.alertRed.withOpacity(0.8);
      case LightPriority.urgent:
        return const Color(0xFFE11D48); // Rose
      case LightPriority.normal:
        return const Color(0xFF059669); // Emerald
    }
  }

  IconData _getLightIcon() {
    switch (light.type) {
      case LightType.doctor:
        return Icons.medical_services;
      case LightType.assistant:
        return Icons.vaccines;
      case LightType.hygiene:
        return Icons.cleaning_services;
      case LightType.emergency:
        return Icons.emergency;
      case LightType.custom:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getLightColor();
    final borderColor = _getBorderColor();
    final isActive = light.isActive;
    final textColor = isActive ? Colors.white : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceSm),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isActive && light.isCritical
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label with icon
            Expanded(
              child: Row(
                children: [
                  Icon(_getLightIcon(), size: 20, color: textColor),
                  const SizedBox(width: AppDimensions.space2xs),
                  Expanded(
                    child: Text(
                      light.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Timer and patient info (if active)
            if (isActive) ...[
              const SizedBox(width: AppDimensions.space2xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      light.timerDisplay,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  // Patient name if available
                  if (light.activatedByName != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: isActive
                                ? const Color(0xFFFFE4E6)
                                : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            light.activatedByName!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive
                                  ? const Color(0xFFFFE4E6)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
