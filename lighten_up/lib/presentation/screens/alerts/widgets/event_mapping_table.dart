import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

import 'event_mapping_row.dart';

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
              child: EventMappingRow(
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
