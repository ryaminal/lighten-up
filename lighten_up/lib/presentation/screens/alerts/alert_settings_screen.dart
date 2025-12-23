import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/event_mapping_table.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/quiet_hours_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/sound_palette_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/visual_settings_card.dart';
import 'package:lighten_up/presentation/screens/alerts/widgets/workstation_selector.dart';

/// Alert configuration screen - orchestrates alert settings components
/// This is the main screen that combines all modular widgets
class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() =>
      _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  String? selectedWorkstationId;
  bool isSelectedTab = true; // true = Selected Workstation, false = Global

  // Mock data - will be replaced with provider data
  final List<Workstation> mockWorkstations = [
    const Workstation(
      id: '1',
      name: 'Front Desk',
      zone: 'Zone A',
      status: WorkstationStatus.active,
    ),
    const Workstation(
      id: '2',
      name: 'Exam Room 1',
      zone: 'Zone B',
      status: WorkstationStatus.active,
    ),
    const Workstation(
      id: '3',
      name: 'Exam Room 2',
      zone: 'Zone B',
      status: WorkstationStatus.active,
    ),
    const Workstation(
      id: '4',
      name: 'Triage Station',
      zone: 'Zone A',
      status: WorkstationStatus.offline,
    ),
    const Workstation(
      id: '5',
      name: 'Nurse Station Main',
      zone: 'Zone C',
      status: WorkstationStatus.active,
    ),
  ];

  late AlertSettings mockSettings;

  @override
  void initState() {
    super.initState();
    selectedWorkstationId = mockWorkstations.first.id;
    mockSettings = AlertSettings(
      id: '1',
      workstationId: selectedWorkstationId!,
      visual: const VisualSettings(
        popupWindow: true,
        flashScreen: true,
        forceFocus: false,
      ),
      eventMappings: [
        const EventMapping(
          id: '1',
          eventName: 'Emergency Call',
          eventDescription: 'Code Blue, Security',
          priority: AlertEventPriority.emergency,
          soundId: 'Urgent Siren',
          volume: 90,
        ),
        const EventMapping(
          id: '2',
          eventName: 'Routine Message',
          eventDescription: 'Internal chat, Check-in',
          priority: AlertEventPriority.normal,
          soundId: 'Soft Chime',
          volume: 45,
        ),
        const EventMapping(
          id: '3',
          eventName: 'Patient Arrived',
          eventDescription: 'Waiting room alert',
          priority: AlertEventPriority.urgent,
          soundId: 'Ding Dong',
          volume: 60,
        ),
        const EventMapping(
          id: '4',
          eventName: 'Lab Results',
          eventDescription: 'Results ready notification',
          priority: AlertEventPriority.low,
          soundId: 'Digital',
          volume: 30,
        ),
      ],
      quietHours: const QuietHours(
        startTime: '22:00',
        endTime: '06:00',
        enabled: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkstationSelector(
                  workstations: mockWorkstations,
                  selectedWorkstationId: selectedWorkstationId,
                  onWorkstationSelected: (id) {
                    setState(() {
                      selectedWorkstationId = id;
                    });
                  },
                ),
                Expanded(child: _buildSettingsPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert Configuration',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage audible and visual notification settings for ${_getSelectedWorkstationName()}',
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
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Selected Workstation', true),
          const SizedBox(width: AppDimensions.spaceLg),
          _buildTab('Global Defaults', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    final bool active = isSelected == isSelectedTab;
    return InkWell(
      onTap: () {
        setState(() {
          isSelectedTab = isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VisualSettingsCard(
            settings: mockSettings.visual,
            onChanged: (visual) {
              setState(() {
                mockSettings = mockSettings.copyWith(visual: visual);
              });
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          SoundPaletteCard(
            selectedSoundId: 'urgent',
            onSoundSelected: (soundId) {
              // TODO: Handle sound selection
              debugPrint('Sound selected: $soundId');
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          EventMappingTable(
            mappings: mockSettings.eventMappings,
            onChanged: (mappings) {
              setState(() {
                mockSettings = mockSettings.copyWith(eventMappings: mappings);
              });
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          QuietHoursCard(
            quietHours: mockSettings.quietHours,
            onChanged: (quietHours) {
              setState(() {
                mockSettings = mockSettings.copyWith(quietHours: quietHours);
              });
            },
          ),
        ],
      ),
    );
  }

  String _getSelectedWorkstationName() {
    final workstation = mockWorkstations.firstWhere(
      (ws) => ws.id == selectedWorkstationId,
      orElse: () => mockWorkstations.first,
    );
    return workstation.name;
  }

  void _testAlert() {
    // TODO: Implement test alert functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test alert would play here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveChanges() {
    // TODO: Implement save functionality via provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
