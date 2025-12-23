import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/utils/extensions.dart';
import 'package:lighten_up/presentation/providers/alert_settings_provider.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/alert_settings_header.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/event_mapping_table.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/quiet_hours_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/settings_tab_selector.dart';
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
          AlertSettingsHeader(
            workstationName: _getSelectedWorkstationName(alertState),
            isLoading: alertState.isLoading,
            onTestAlert: _testAlert,
            onSaveChanges: () => _saveChanges(alertState, notifier),
          ),
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

  Widget _buildLoadingOrEmpty(AlertSettingsState alertState) {
    if (alertState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (alertState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
          SettingsTabSelector(
            isSelectedTab: isSelectedTab,
            onSelectedWorkstationTap: () {
              setState(() {
                isSelectedTab = true;
              });
            },
            onGlobalDefaultsTap: () {
              setState(() {
                isSelectedTab = false;
              });
              notifier.loadGlobalSettings();
            },
          ),
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
    context.showInfo('Test alert would play here');
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
        context.showSuccess('Settings saved successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showError('Failed to save settings: ${e.toString()}');
      }
    }
  }
}
