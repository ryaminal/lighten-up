import 'package:flutter/foundation.dart';
import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';
import 'package:lighten_up/presentation/providers/mock_alert_settings_data.dart';
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
@Riverpod(keepAlive: true)
class AlertSettingsNotifier extends _$AlertSettingsNotifier {
  @override
  AlertSettingsState build() {
    // Load mock data synchronously during initialization
    // This avoids async lifecycle issues with Riverpod's build() method
    // When connecting to real API, consider using AsyncNotifierProvider instead
    final workstations = MockAlertSettingsData.getWorkstations();

    if (workstations.isEmpty) {
      return const AlertSettingsState(isLoading: false);
    }

    // Load settings for first workstation synchronously
    final firstWorkstation = workstations.first;
    final settings = MockAlertSettingsData.getSettingsForWorkstation(
      firstWorkstation.id,
    );

    return AlertSettingsState(
      workstations: workstations,
      selectedWorkstationId: firstWorkstation.id,
      selectedWorkstationSettings: settings,
      isLoading: false,
    );
  }

  /// Load all workstations
  Future<void> _loadWorkstations() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final workstations = MockAlertSettingsData.getWorkstations();

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

  /// Refresh workstations list
  Future<void> refreshWorkstations() async {
    await _loadWorkstations();
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

      final settings = MockAlertSettingsData.getSettingsForWorkstation(
        workstationId,
      );

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

      final settings = MockAlertSettingsData.getGlobalSettings();

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
}
