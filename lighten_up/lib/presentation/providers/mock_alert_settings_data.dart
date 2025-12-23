import 'package:lighten_up/data/models/alert_settings.dart';
import 'package:lighten_up/data/models/workstation.dart';

/// Mock data for alert settings - will be replaced with actual API calls
class MockAlertSettingsData {
  MockAlertSettingsData._();

  /// Get mock workstations
  static List<Workstation> getWorkstations() {
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

  /// Get mock settings for a specific workstation
  static AlertSettings getSettingsForWorkstation(String workstationId) {
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

  /// Get mock global settings
  static AlertSettings getGlobalSettings() {
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
