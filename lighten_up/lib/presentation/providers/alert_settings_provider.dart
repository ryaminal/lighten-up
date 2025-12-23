import 'package:flutter/foundation.dart';
import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alert_settings_provider.g.dart';

/// State for alert settings
class AlertSettingsState {
  final List<Workstation> workstations;
  final AlertSettings? selectedWorkstationSettings;
  final AlertSettings? globalSettings;
  final String? selectedWorkstationId;
  final bool isLoading;
  final String? error;

  const AlertSettingsState({
    this.workstations = const [],
    this.selectedWorkstationSettings,
    this.globalSettings,
    this.selectedWorkstationId,
    this.isLoading = false,
    this.error,
  });

  AlertSettingsState copyWith({
    List<Workstation>? workstations,
    AlertSettings? selectedWorkstationSettings,
    AlertSettings? globalSettings,
    String? selectedWorkstationId,
    bool? isLoading,
    String? error,
  }) {
    return AlertSettingsState(
      workstations: workstations ?? this.workstations,
      selectedWorkstationSettings:
          selectedWorkstationSettings ?? this.selectedWorkstationSettings,
      globalSettings: globalSettings ?? this.globalSettings,
      selectedWorkstationId:
          selectedWorkstationId ?? this.selectedWorkstationId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for managing alert settings
@riverpod
class AlertSettingsNotifier extends _$AlertSettingsNotifier {
  @override
  AlertSettingsState build() {
    // Initialize with empty state
    _loadWorkstations();
    return const AlertSettingsState();
  }

  /// Load all workstations
  Future<void> _loadWorkstations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final workstations = _getMockWorkstations();

      state = state.copyWith(
        workstations: workstations,
        selectedWorkstationId: workstations.isNotEmpty
            ? workstations.first.id
            : null,
        isLoading: false,
      );

      // Load settings for first workstation
      if (workstations.isNotEmpty) {
        await loadSettingsForWorkstation(workstations.first.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load workstations: ${e.toString()}',
      );
    }
  }

  /// Load settings for a specific workstation
  Future<void> loadSettingsForWorkstation(String workstationId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedWorkstationId: workstationId,
    );

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      final settings = _getMockSettingsForWorkstation(workstationId);

      state = state.copyWith(
        selectedWorkstationSettings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: ${e.toString()}',
      );
    }
  }

  /// Load global default settings
  Future<void> loadGlobalSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      final settings = _getMockGlobalSettings();

      state = state.copyWith(globalSettings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load global settings: ${e.toString()}',
      );
    }
  }

  /// Save settings for selected workstation
  Future<void> saveSettings(AlertSettings settings) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('Saving settings: ${settings.toJson()}');

      state = state.copyWith(
        selectedWorkstationSettings: settings,
        isLoading: false,
      );

      // Success feedback handled by UI
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save settings: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Update visual settings
  void updateVisualSettings(VisualSettings visual) {
    if (state.selectedWorkstationSettings != null) {
      state = state.copyWith(
        selectedWorkstationSettings: state.selectedWorkstationSettings!
            .copyWith(visual: visual),
      );
    }
  }

  /// Update event mappings
  void updateEventMappings(List<EventMapping> mappings) {
    if (state.selectedWorkstationSettings != null) {
      state = state.copyWith(
        selectedWorkstationSettings: state.selectedWorkstationSettings!
            .copyWith(eventMappings: mappings),
      );
    }
  }

  /// Update quiet hours
  void updateQuietHours(QuietHours quietHours) {
    if (state.selectedWorkstationSettings != null) {
      state = state.copyWith(
        selectedWorkstationSettings: state.selectedWorkstationSettings!
            .copyWith(quietHours: quietHours),
      );
    }
  }

  // Mock data - will be replaced with actual API calls

  List<Workstation> _getMockWorkstations() {
    return [
      const Workstation(
        id: '1',
        name: 'Front Desk',
        zone: 'Reception',
        status: WorkstationStatus.active,
      ),
      const Workstation(
        id: '2',
        name: 'Doctor Office 1',
        zone: 'Doctor\'s Wing',
        status: WorkstationStatus.active,
      ),
      const Workstation(
        id: '3',
        name: 'Hygiene Room 1',
        zone: 'Hygiene Wing',
        status: WorkstationStatus.active,
      ),
      const Workstation(
        id: '4',
        name: 'Lab Workstation',
        zone: 'Laboratory',
        status: WorkstationStatus.offline,
      ),
    ];
  }

  AlertSettings _getMockSettingsForWorkstation(String workstationId) {
    return AlertSettings(
      id: 'settings-$workstationId',
      workstationId: workstationId,
      visual: const VisualSettings(
        popupWindow: true,
        flashScreen: true,
        forceFocus: false,
      ),
      eventMappings: const [
        EventMapping(
          id: '1',
          eventName: 'Emergency Call',
          eventDescription: 'Code Blue, Security',
          priority: AlertEventPriority.emergency,
          soundId: 'Urgent Siren',
          volume: 90,
        ),
        EventMapping(
          id: '2',
          eventName: 'Routine Message',
          eventDescription: 'Internal chat, Check-in',
          priority: AlertEventPriority.normal,
          soundId: 'Soft Chime',
          volume: 45,
        ),
        EventMapping(
          id: '3',
          eventName: 'Patient Arrived',
          eventDescription: 'Waiting room alert',
          priority: AlertEventPriority.urgent,
          soundId: 'Ding Dong',
          volume: 60,
        ),
        EventMapping(
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

  AlertSettings _getMockGlobalSettings() {
    return const AlertSettings(
      id: 'global-settings',
      workstationId: 'global',
      visual: VisualSettings(
        popupWindow: true,
        flashScreen: false,
        forceFocus: false,
      ),
      eventMappings: [
        EventMapping(
          id: '1',
          eventName: 'Emergency Call',
          eventDescription: 'Code Blue, Security',
          priority: AlertEventPriority.emergency,
          soundId: 'Urgent Siren',
          volume: 85,
        ),
        EventMapping(
          id: '2',
          eventName: 'Routine Message',
          eventDescription: 'Internal chat, Check-in',
          priority: AlertEventPriority.normal,
          soundId: 'Soft Chime',
          volume: 50,
        ),
      ],
      quietHours: QuietHours(
        startTime: '22:00',
        endTime: '06:00',
        enabled: true,
      ),
    );
  }
}
