import 'package:lighten_up/data/models/alert.dart';

/// Mock data for alerts - will be replaced with actual API calls
/// Separated from UI components to follow Single Responsibility Principle
class MockAlertData {
  MockAlertData._();

  /// Get mock alerts for development/testing
  static List<Alert> getAlerts() {
    return [
      Alert(
        id: '1',
        title: 'Exam Room 1',
        description: 'Code Blue',
        type: AlertType.emergency,
        severity: AlertSeverity.emergency,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(seconds: 45)),
      ),
      Alert(
        id: '2',
        title: 'Triage 3',
        description: 'Nurse Needed',
        type: AlertType.medical,
        severity: AlertSeverity.high,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Alert(
        id: '3',
        title: 'Exam Room 4',
        description: 'Patient Ready',
        type: AlertType.medical,
        severity: AlertSeverity.medium,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Alert(
        id: '4',
        title: 'Hygiene 2',
        description: 'Room Available',
        type: AlertType.system,
        severity: AlertSeverity.low,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
  }
}
