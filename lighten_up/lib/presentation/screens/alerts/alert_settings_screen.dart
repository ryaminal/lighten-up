import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';

/// Alert configuration screen for managing notification settings per workstation
class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() =>
      _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  String? selectedWorkstationId;
  String searchQuery = '';
  bool isSelectedTab =
      true; // true = Selected Workstation, false = Global Defaults

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

  final AlertSettings mockSettings = const AlertSettings(
    id: '1',
    workstationId: '1',
    visual: VisualSettings(
      popupWindow: true,
      flashScreen: true,
      forceFocus: false,
    ),
    eventMappings: [],
    quietHours: QuietHours(
      startTime: '22:00',
      endTime: '06:00',
      enabled: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    selectedWorkstationId = mockWorkstations.first.id;
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
                _buildWorkstationSelector(),
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
                  'Manage audible and visual notification settings for Front Desk',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Test alert
            },
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text('Test Alert'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          ElevatedButton(
            onPressed: () {
              // TODO: Save changes
            },
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

  Widget _buildWorkstationSelector() {
    final filteredWorkstations = mockWorkstations
        .where(
          (ws) => ws.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search workstations...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          // Workstation list
          Expanded(
            child: ListView.separated(
              itemCount: filteredWorkstations.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceSm),
              itemBuilder: (context, index) {
                final workstation = filteredWorkstations[index];
                final isSelected = workstation.id == selectedWorkstationId;
                final isActive = workstation.status == WorkstationStatus.active;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedWorkstationId = workstation.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: workstation.id,
                          groupValue: selectedWorkstationId,
                          onChanged: (value) {
                            setState(() {
                              selectedWorkstationId = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    workstation.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.successGreen
                                          : AppColors.textSecondary,
                                      shape: BoxShape.circle,
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: AppColors.successGreen
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workstation.zone} • ${isActive ? 'Active' : 'Offline'}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVisualInterruptionsCard(),
          const SizedBox(height: AppDimensions.spaceMd),
          _buildSoundPaletteCard(),
          const SizedBox(height: AppDimensions.spaceMd),
          _buildEventConfigurationCard(),
          const SizedBox(height: AppDimensions.spaceMd),
          _buildQuietHoursCard(),
        ],
      ),
    );
  }

  Widget _buildVisualInterruptionsCard() {
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
              Icon(Icons.visibility, color: AppColors.primary, size: 24),
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
                child: _buildVisualSettingCard(
                  icon: Icons.web_asset,
                  title: 'Pop-up Window',
                  description: 'Show alert dialogue on top of other windows.',
                  value: mockSettings.visual.popupWindow,
                  onChanged: (value) {
                    // TODO: Update settings
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: _buildVisualSettingCard(
                  icon: Icons.flourescent,
                  title: 'Flash Screen',
                  description: 'Screen borders flash color of alert urgency.',
                  value: mockSettings.visual.flashScreen,
                  onChanged: (value) {
                    // TODO: Update settings
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: _buildVisualSettingCard(
                  icon: Icons.warning,
                  title: 'Force Focus',
                  description:
                      'Steal input focus from other apps (Use caution).',
                  value: mockSettings.visual.forceFocus,
                  onChanged: (value) {
                    // TODO: Update settings
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSettingCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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

  Widget _buildSoundPaletteCard() {
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

    String selectedSoundId = 'urgent';

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
                  Icon(Icons.piano, color: AppColors.primary, size: 24),
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
              return InkWell(
                onTap: () {
                  // TODO: Play sound preview
                },
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
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sound.name,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventConfigurationCard() {
    final events = [
      _EventRow(
        name: 'Emergency Call',
        description: 'Code Blue, Security',
        priority: AlertEventPriority.emergency,
        sound: 'Urgent Siren',
        volume: 90,
      ),
      _EventRow(
        name: 'Routine Message',
        description: 'Internal chat, Check-in',
        priority: AlertEventPriority.normal,
        sound: 'Soft Chime',
        volume: 45,
      ),
      _EventRow(
        name: 'Patient Arrived',
        description: 'Waiting room alert',
        priority: AlertEventPriority.urgent,
        sound: 'Ding Dong',
        volume: 60,
      ),
      _EventRow(
        name: 'Lab Results',
        description: 'Results ready notification',
        priority: AlertEventPriority.low,
        sound: 'Digital',
        volume: 30,
      ),
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
            children: [
              Icon(Icons.tune, color: AppColors.primary, size: 24),
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
          // Header row
          Container(
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
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          // Event rows
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(event.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  event.description,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: event.sound,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceSm,
                            vertical: AppDimensions.spaceSm,
                          ),
                        ),
                        dropdownColor: AppColors.surfaceCard,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                        items:
                            [
                              'Urgent Siren',
                              'Soft Chime',
                              'Ding Dong',
                              'Digital',
                              'Sonar',
                              'None',
                            ].map((sound) {
                              return DropdownMenuItem(
                                value: sound,
                                child: Text(sound),
                              );
                            }).toList(),
                        onChanged: (value) {
                          // TODO: Update sound
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Icon(
                            event.volume > 50
                                ? Icons.volume_up
                                : Icons.volume_down,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spaceSm),
                          Expanded(
                            child: Slider(
                              value: event.volume.toDouble(),
                              min: 0,
                              max: 100,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.surfaceCard,
                              onChanged: (value) {
                                // TODO: Update volume
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceSm),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${event.volume}%',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              Icons.bedtime,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet Hours (Auto-Mute)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Automatically mute non-emergency alerts during these hours.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: TextEditingController(
                    text: mockSettings.quietHours?.startTime ?? '22:00',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceSm,
                      vertical: AppDimensions.spaceSm,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    // TODO: Show time picker
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSm,
                ),
                child: Text(
                  'to',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: TextEditingController(
                    text: mockSettings.quietHours?.endTime ?? '06:00',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceSm,
                      vertical: AppDimensions.spaceSm,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    // TODO: Show time picker
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Switch(
                value: mockSettings.quietHours?.enabled ?? false,
                onChanged: (value) {
                  // TODO: Update quiet hours enabled
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
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

class _EventRow {
  final String name;
  final String description;
  final AlertEventPriority priority;
  final String sound;
  final int volume;

  _EventRow({
    required this.name,
    required this.description,
    required this.priority,
    required this.sound,
    required this.volume,
  });
}
