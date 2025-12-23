import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/utils/extensions.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

/// Quiet hours configuration card
class QuietHoursCard extends StatelessWidget {
  final QuietHours? quietHours;
  final ValueChanged<QuietHours> onChanged;

  const QuietHoursCard({super.key, this.quietHours, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hours =
        quietHours ??
        const QuietHours(startTime: '22:00', endTime: '06:00', enabled: false);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.bedtime,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet Hours (Auto-Mute)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Automatically mute non-emergency alerts during these hours.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Row(
            children: [
              _TimeField(
                time: hours.startTime,
                onTimeChanged: (time) {
                  onChanged(hours.copyWith(startTime: time));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSm,
                ),
                child: Text(
                  'to',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _TimeField(
                time: hours.endTime,
                onTimeChanged: (time) {
                  onChanged(hours.copyWith(endTime: time));
                },
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Switch(
                value: hours.enabled,
                onChanged: (value) {
                  onChanged(hours.copyWith(enabled: value));
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String time;
  final ValueChanged<String> onTimeChanged;

  const _TimeField({required this.time, required this.onTimeChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: TextEditingController(text: time),
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceSm,
            vertical: AppDimensions.spaceSm,
          ),
        ),
        readOnly: true,
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: _parseTime(time),
          );
          if (picked != null) {
            onTimeChanged(_formatTime(picked));
          }
        },
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return time.to24HourString();
  }
}
