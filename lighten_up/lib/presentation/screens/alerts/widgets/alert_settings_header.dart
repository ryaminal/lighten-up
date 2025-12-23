import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';

/// Header for alert settings screen with title, description, and action buttons
class AlertSettingsHeader extends StatelessWidget {
  final String workstationName;
  final bool isLoading;
  final VoidCallback onTestAlert;
  final VoidCallback onSaveChanges;

  const AlertSettingsHeader({
    super.key,
    required this.workstationName,
    required this.isLoading,
    required this.onTestAlert,
    required this.onSaveChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Text(
                      'Alert Settings',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage audible and visual notification settings for $workstationName',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          OutlinedButton.icon(
            onPressed: onTestAlert,
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text('Test Alert'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          ElevatedButton(
            onPressed: isLoading ? null : onSaveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
