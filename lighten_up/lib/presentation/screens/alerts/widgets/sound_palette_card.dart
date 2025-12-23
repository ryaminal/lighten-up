import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';

/// Sound palette card for selecting notification sounds
class SoundPaletteCard extends StatelessWidget {
  final String? selectedSoundId;
  final ValueChanged<String> onSoundSelected;

  const SoundPaletteCard({
    super.key,
    this.selectedSoundId,
    required this.onSoundSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sounds = [
      const SoundOption(id: 'chime', name: 'Chime', icon: 'notifications'),
      const SoundOption(
        id: 'sonar',
        name: 'Sonar',
        icon: 'notifications_active',
      ),
      const SoundOption(id: 'urgent', name: 'Urgent', icon: 'campaign'),
      const SoundOption(id: 'ding', name: 'Ding Dong', icon: 'doorbell'),
      const SoundOption(id: 'digital', name: 'Digital', icon: 'smartphone'),
      const SoundOption(id: 'mute', name: 'Mute', icon: 'piano_off'),
    ];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.piano, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Text(
                    'Sound Palette',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  'Click to preview',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Wrap(
            spacing: AppDimensions.spaceSm,
            runSpacing: AppDimensions.spaceSm,
            children: sounds.map((sound) {
              final isSelected = sound.id == selectedSoundId;
              return _SoundButton(
                sound: sound,
                isSelected: isSelected,
                onTap: () => onSoundSelected(sound.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SoundButton extends StatelessWidget {
  final SoundOption sound;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundButton({
    required this.sound,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getIconFromString(sound.icon),
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              sound.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'notifications':
        return Icons.notifications;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'campaign':
        return Icons.campaign;
      case 'doorbell':
        return Icons.doorbell;
      case 'smartphone':
        return Icons.smartphone;
      case 'piano_off':
        return Icons.piano_off;
      default:
        return Icons.notifications;
    }
  }
}
