import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/room.dart';

/// Dialog for light actions (activate/acknowledge)
class LightActionDialog extends StatelessWidget {
  final Room room;
  final RoomLight light;
  final VoidCallback? onActivate;
  final VoidCallback? onAcknowledge;

  const LightActionDialog({
    super.key,
    required this.room,
    required this.light,
    this.onActivate,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text(
        '${room.displayLabel} - ${light.label}',
        style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            light.isActive ? 'Light is ACTIVE' : 'Light is inactive',
            style: AppTextStyles.bodyMedium.copyWith(
              color: light.isActive
                  ? AppColors.alertGreen
                  : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (light.isActive) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              'Active for: ${light.timerDisplay}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            if (light.activatedByName != null) ...[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                'Activated by: ${light.activatedByName}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ],
        ],
      ),
      actions: [
        if (!light.isActive && onActivate != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onActivate?.call();
            },
            child: const Text('Activate'),
          ),
        if (light.isActive && onAcknowledge != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAcknowledge?.call();
            },
            child: const Text('Acknowledge'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Helper method to show the dialog
  static void show(
    BuildContext context,
    Room room,
    RoomLight light, {
    VoidCallback? onActivate,
    VoidCallback? onAcknowledge,
  }) {
    showDialog(
      context: context,
      builder: (context) => LightActionDialog(
        room: room,
        light: light,
        onActivate: onActivate,
        onAcknowledge: onAcknowledge,
      ),
    );
  }
}
