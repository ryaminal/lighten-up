import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

/// Event configuration table with sound assignments and volume control
class EventMappingTable extends StatelessWidget {
  final List<EventMapping> mappings;
  final ValueChanged<List<EventMapping>> onChanged;

  const EventMappingTable({
    super.key,
    required this.mappings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.primary, size: 24),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                'Event Configuration',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          _buildTableHeader(),
          const SizedBox(height: AppDimensions.spaceSm),
          ...mappings.asMap().entries.map((entry) {
            final index = entry.key;
            final mapping = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
              child: _EventMappingRow(
                mapping: mapping,
                onChanged: (updated) {
                  final newMappings = List<EventMapping>.from(mappings);
                  newMappings[index] = updated;
                  onChanged(newMappings);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'EVENT TRIGGER',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'ASSIGNED SOUND',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'VOLUME',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMappingRow extends StatelessWidget {
  final EventMapping mapping;
  final ValueChanged<EventMapping> onChanged;

  const _EventMappingRow({required this.mapping, required this.onChanged});

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
    final availableSounds = [
      'Urgent Siren',
      'Soft Chime',
      'Ding Dong',
      'Digital',
      'Sonar',
      'None',
    ];

    return DropdownButtonFormField<String>(
      value: mapping.soundId,
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
        return DropdownMenuItem(value: sound, child: Text(sound));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(mapping.copyWith(soundId: value));
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
