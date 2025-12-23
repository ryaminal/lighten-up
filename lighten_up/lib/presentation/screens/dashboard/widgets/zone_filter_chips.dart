import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/room.dart';

/// Zone filter chips for filtering rooms by zone
class ZoneFilterChips extends StatelessWidget {
  final List<ZoneType> zones;
  final ZoneType? selectedZone;
  final ValueChanged<ZoneType?> onZoneSelected;

  const ZoneFilterChips({
    super.key,
    required this.zones,
    this.selectedZone,
    required this.onZoneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Wrap(
        spacing: AppDimensions.spaceSm,
        runSpacing: AppDimensions.spaceSm,
        children: [
          // "All Zones" chip (null value for no filter)
          _buildZoneChip('All Zones', null),
          // Individual zone chips
          ...zones.map((zone) => _buildZoneChip(zone.displayName, zone)),
        ],
      ),
    );
  }

  Widget _buildZoneChip(String label, ZoneType? zone) {
    final isSelected = selectedZone == zone;
    return InkWell(
      onTap: () => onZoneSelected(zone),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
