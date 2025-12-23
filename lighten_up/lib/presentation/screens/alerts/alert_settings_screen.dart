import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/presentation/providers/alert_settings_provider.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/event_mapping_table.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/quiet_hours_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/sound_palette_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/visual_settings_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/workstation_selector.dart';

/// Alert configuration screen - orchestrates alert settings components
/// Uses AlertSettingsProvider for state management
class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() =>
      _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  bool isSelectedTab = true; // true = Selected Workstation, false = Global

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertSettingsNotifierProvider);
    final notifier = ref.read(alertSettingsNotifierProvider.notifier);

    final currentSettings = isSelectedTab
        ? alertState.selectedWorkstationSettings
        : alertState.globalSettings;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(alertState, notifier),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkstationSelector(
                  workstations: alertState.workstations,
                  selectedWorkstationId: alertState.selectedWorkstationId,
                  onWorkstationSelected: (id) {
                    if (id != null) {
                      notifier.loadSettingsForWorkstation(id);
                    }
                  },
                ),
                Expanded(
                  child: currentSettings == null
                      ? _buildLoadingOrEmpty(alertState)
                      : _buildSettingsPanel(currentSettings, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    AlertSettingsState alertState,
    AlertSettingsNotifier notifier,
  ) {
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
                    Icon(Icons.settings, color: AppColors.primary, size: 28),
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
                  'Manage audible and visual notification settings for ${_getSelectedWorkstationName(alertState)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          OutlinedButton.icon(
            onPressed: _testAlert,
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text('Test Alert'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          ElevatedButton(
            onPressed: alertState.isLoading
                ? null
                : () => _saveChanges(alertState, notifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: alertState.isLoading
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

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Selected Workstation', isSelectedTab, () {
            setState(() {
              isSelectedTab = true;
            });
          }),
          const SizedBox(width: AppDimensions.spaceSm),
          _buildTabButton('Global Defaults', !isSelectedTab, () {
            setState(() {
              isSelectedTab = false;
            });
            final notifier = ref.read(alertSettingsNotifierProvider.notifier);
            notifier.loadGlobalSettings();
          }),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
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

  Widget _buildLoadingOrEmpty(AlertSettingsState alertState) {
    if (alertState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (alertState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.spaceMd),
            Text(
              alertState.error!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        'No settings available',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(dynamic settings, AlertSettingsNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabSelector(),
          const SizedBox(height: AppDimensions.spaceLg),
          VisualSettingsCard(
            settings: settings.visual,
            onChanged: (visual) {
              notifier.updateVisualSettings(visual);
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          SoundPaletteCard(
            selectedSoundId: 'urgent',
            onSoundSelected: (soundId) {
              debugPrint('Sound selected: $soundId');
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          EventMappingTable(
            mappings: settings.eventMappings,
            onChanged: (mappings) {
              notifier.updateEventMappings(mappings);
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          QuietHoursCard(
            quietHours: settings.quietHours,
            onChanged: (quietHours) {
              notifier.updateQuietHours(quietHours);
            },
          ),
        ],
      ),
    );
  }

  String _getSelectedWorkstationName(AlertSettingsState alertState) {
    if (alertState.selectedWorkstationId == null) {
      return 'workstation';
    }
    final workstation = alertState.workstations.firstWhere(
      (ws) => ws.id == alertState.selectedWorkstationId,
      orElse: () => alertState.workstations.first,
    );
    return workstation.name;
  }

  void _testAlert() {
    // TODO: Implement test alert functionality
    debugPrint('Test Alert clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test alert would play here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveChanges(
    AlertSettingsState alertState,
    AlertSettingsNotifier notifier,
  ) async {
    final currentSettings = isSelectedTab
        ? alertState.selectedWorkstationSettings
        : alertState.globalSettings;

    if (currentSettings == null) return;

    try {
      await notifier.saveSettings(currentSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully'),
            backgroundColor: AppColors.alertGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
