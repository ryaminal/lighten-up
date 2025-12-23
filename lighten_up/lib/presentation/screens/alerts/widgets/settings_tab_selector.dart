import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';

/// Tab selector for switching between Selected Workstation and Global Defaults
class SettingsTabSelector extends StatelessWidget {
  final bool isSelectedTab;
  final VoidCallback onSelectedWorkstationTap;
  final VoidCallback onGlobalDefaultsTap;

  const SettingsTabSelector({
    super.key,
    required this.isSelectedTab,
    required this.onSelectedWorkstationTap,
    required this.onGlobalDefaultsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'Selected Workstation',
            isActive: isSelectedTab,
            onTap: onSelectedWorkstationTap,
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          _TabButton(
            label: 'Global Defaults',
            isActive: !isSelectedTab,
            onTap: onGlobalDefaultsTap,
          ),
        ],
      ),
    );
  }
}

/// Private tab button widget
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
