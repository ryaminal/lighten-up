import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/room.dart';

/// Light button widget for room lights
class RoomLightButton extends StatelessWidget {
  final RoomLight light;
  final VoidCallback? onTap;

  const RoomLightButton({super.key, required this.light, this.onTap});

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
                    color: borderColor.withValues(alpha: 0.3),
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
              _ActiveLightInfo(light: light),
            ],
          ],
        ),
      ),
    );
  }

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
        return AppColors.alertRed.withValues(alpha: 0.8);
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
}

/// Active light information widget (timer and patient name)
class _ActiveLightInfo extends StatelessWidget {
  final RoomLight light;

  const _ActiveLightInfo({required this.light});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 12, color: Color(0xFFFFE4E6)),
                const SizedBox(width: 4),
                Text(
                  light.activatedByName!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFFFE4E6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
