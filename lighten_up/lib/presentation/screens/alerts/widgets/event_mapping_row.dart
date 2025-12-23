import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

/// Event mapping row widget with sound assignment and volume control
class EventMappingRow extends StatelessWidget {
  final EventMapping mapping;
  final ValueChanged<EventMapping> onChanged;

  const EventMappingRow({
    super.key,
    required this.mapping,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: _buildEventInfo()),
          Expanded(flex: 4, child: _buildSoundDropdown()),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(flex: 4, child: _buildVolumeControl()),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getPriorityColor(mapping.priority),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mapping.eventName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                mapping.eventDescription,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundDropdown() {
    // Use all SoundType enum values
    const availableSounds = SoundType.values;

    return DropdownButtonFormField<SoundType>(
      value: mapping.soundType,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSm,
          vertical: AppDimensions.spaceSm,
        ),
      ),
      dropdownColor: AppColors.surfaceCard,
      style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      items: availableSounds.map((sound) {
        return DropdownMenuItem(value: sound, child: Text(sound.displayName));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(mapping.copyWith(soundType: value));
        }
      },
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        Icon(
          mapping.volume > 50 ? Icons.volume_up : Icons.volume_down,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceCard,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: mapping.volume.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) {
                onChanged(mapping.copyWith(volume: value.round()));
              },
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        SizedBox(
          width: 36,
          child: Text(
            '${mapping.volume}%',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(AlertEventPriority priority) {
    switch (priority) {
      case AlertEventPriority.emergency:
        return AppColors.alertRed;
      case AlertEventPriority.urgent:
        return AppColors.alertOrange;
      case AlertEventPriority.normal:
        return AppColors.primary;
      case AlertEventPriority.low:
        return AppColors.alertPurple;
    }
  }
}
