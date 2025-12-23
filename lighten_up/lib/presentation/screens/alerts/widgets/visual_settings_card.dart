import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

/// Visual interruptions settings card
/// Displays toggle switches for popup, flash, and force focus options
class VisualSettingsCard extends StatelessWidget {
  final VisualSettings settings;
  final ValueChanged<VisualSettings> onChanged;

  const VisualSettingsCard({
    super.key,
    required this.settings,
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
              const Icon(Icons.visibility, color: AppColors.primary, size: 24),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                'Visual Interruptions',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: _VisualSettingCard(
                  icon: Icons.web_asset,
                  title: 'Pop-up Window',
                  description: 'Show alert dialogue on top of other windows.',
                  value: settings.popupWindow,
                  onChanged: (value) {
                    onChanged(settings.copyWith(popupWindow: value));
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: _VisualSettingCard(
                  icon: Icons.flourescent,
                  title: 'Flash Screen',
                  description: 'Screen borders flash color of alert urgency.',
                  value: settings.flashScreen,
                  onChanged: (value) {
                    onChanged(settings.copyWith(flashScreen: value));
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: _VisualSettingCard(
                  icon: Icons.warning,
                  title: 'Force Focus',
                  description:
                      'Steal input focus from other apps (Use caution).',
                  value: settings.forceFocus,
                  onChanged: (value) {
                    onChanged(settings.copyWith(forceFocus: value));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisualSettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _VisualSettingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
