import 'package:flutter_test/flutter_test.dart';
import 'package:lighten_up/data/models/alert.dart';
import 'package:lighten_up/presentation/providers/alert_provider.dart';
import 'package:lighten_up/core/utils/logger.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AlertProvider - Behavior Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Set log level to only show errors during tests (clean output)
      AppLogger.setLevel(Level.error);

      // Create a new provider container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initialization', () {
      test('provider initializes with loaded data', () {
        // Act - Read the provider
        final state = container.read(alertNotifierProvider);

        // Assert - Data is loaded synchronously from mock data
        expect(state.alerts, isNotEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('alerts are loaded from mock data', () {
        // Act
        final state = container.read(alertNotifierProvider);

        // Assert - 4 mock alerts
        expect(state.alerts.length, equals(4));
      });

      test('mock alerts have expected types', () {
        // Act
        final state = container.read(alertNotifierProvider);

        // Assert - Check alert types
        final types = state.alerts.map((a) => a.type).toList();
        expect(types, contains(AlertType.emergency));
        expect(types, contains(AlertType.medical));
        expect(types, contains(AlertType.system));
      });

      test('mock alerts have expected severities', () {
        // Act
        final state = container.read(alertNotifierProvider);

        // Assert - Check alert severities
        final severities = state.alerts.map((a) => a.severity).toList();
        expect(severities, contains(AlertSeverity.emergency));
        expect(severities, contains(AlertSeverity.high));
        expect(severities, contains(AlertSeverity.medium));
        expect(severities, contains(AlertSeverity.low));
      });
    });

    group('Alert Queries', () {
      test('urgentAlerts returns only critical/emergency alerts', () {
        // Arrange
        final state = container.read(alertNotifierProvider);

        // Act
        final urgentAlerts = state.urgentAlerts;

        // Assert
        expect(urgentAlerts, isNotEmpty);
        for (final alert in urgentAlerts) {
          expect(alert.isCritical, isTrue);
        }
      });

      test('roomStatusAlerts returns only non-critical alerts', () {
        // Arrange
        final state = container.read(alertNotifierProvider);

        // Act
        final roomStatusAlerts = state.roomStatusAlerts;

        // Assert
        expect(roomStatusAlerts, isNotEmpty);
        for (final alert in roomStatusAlerts) {
          expect(alert.isCritical, isFalse);
        }
      });

      test('activeAlerts returns only active status alerts', () {
        // Arrange
        final state = container.read(alertNotifierProvider);

        // Act
        final activeAlerts = state.activeAlerts;

        // Assert - All mock alerts are active initially
        expect(activeAlerts.length, equals(4));
        for (final alert in activeAlerts) {
          expect(alert.status, equals(AlertStatus.active));
        }
      });

      test('urgentAlertCount matches number of urgent alerts', () {
        // Arrange
        final state = container.read(alertNotifierProvider);

        // Act
        final count = state.urgentAlertCount;
        final urgentAlerts = state.urgentAlerts;

        // Assert
        expect(count, equals(urgentAlerts.length));
      });

      test('getAlertsByType filters alerts by type', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);

        // Act
        final medicalAlerts = notifier.getAlertsByType(AlertType.medical);
        final emergencyAlerts = notifier.getAlertsByType(AlertType.emergency);

        // Assert
        expect(medicalAlerts.isNotEmpty, isTrue);
        for (final alert in medicalAlerts) {
          expect(alert.type, equals(AlertType.medical));
        }
        expect(emergencyAlerts.isNotEmpty, isTrue);
        for (final alert in emergencyAlerts) {
          expect(alert.type, equals(AlertType.emergency));
        }
      });

      test('getAlertsBySeverity filters alerts by severity', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);

        // Act
        final emergencySeverity = notifier.getAlertsBySeverity(
          AlertSeverity.emergency,
        );
        final highSeverity = notifier.getAlertsBySeverity(AlertSeverity.high);

        // Assert
        expect(emergencySeverity.isNotEmpty, isTrue);
        for (final alert in emergencySeverity) {
          expect(alert.severity, equals(AlertSeverity.emergency));
        }
        expect(highSeverity.isNotEmpty, isTrue);
        for (final alert in highSeverity) {
          expect(alert.severity, equals(AlertSeverity.high));
        }
      });
    });

    group('Alert Status Management', () {
      test('acknowledgeAlert changes alert status to acknowledged', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToAck = initialState.alerts.first;

        // Act
        await notifier.acknowledgeAlert(alertToAck.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        final updatedAlert = updatedState.alerts.firstWhere(
          (a) => a.id == alertToAck.id,
        );
        expect(updatedAlert.status, equals(AlertStatus.acknowledged));
      });

      test('acknowledgeAlert preserves other alerts unchanged', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToAck = initialState.alerts.first;
        final otherAlerts = initialState.alerts
            .where((a) => a.id != alertToAck.id)
            .toList();

        // Act
        await notifier.acknowledgeAlert(alertToAck.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        for (final otherAlert in otherAlerts) {
          final stillUnchanged = updatedState.alerts.firstWhere(
            (a) => a.id == otherAlert.id,
          );
          expect(stillUnchanged.status, equals(otherAlert.status));
        }
      });

      test('cancelAlert changes alert status to cancelled', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToCancel = initialState.alerts.first;

        // Act
        await notifier.cancelAlert(alertToCancel.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        final updatedAlert = updatedState.alerts.firstWhere(
          (a) => a.id == alertToCancel.id,
        );
        expect(updatedAlert.status, equals(AlertStatus.cancelled));
      });

      test('resolveAlert changes alert status to resolved', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToResolve = initialState.alerts.first;

        // Act
        await notifier.resolveAlert(alertToResolve.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        final updatedAlert = updatedState.alerts.firstWhere(
          (a) => a.id == alertToResolve.id,
        );
        expect(updatedAlert.status, equals(AlertStatus.resolved));
      });

      test('multiple status changes work correctly', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alert1 = initialState.alerts[0];
        final alert2 = initialState.alerts[1];
        final alert3 = initialState.alerts[2];

        // Act
        await notifier.acknowledgeAlert(alert1.id);
        await notifier.cancelAlert(alert2.id);
        await notifier.resolveAlert(alert3.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        expect(
          updatedState.alerts.firstWhere((a) => a.id == alert1.id).status,
          equals(AlertStatus.acknowledged),
        );
        expect(
          updatedState.alerts.firstWhere((a) => a.id == alert2.id).status,
          equals(AlertStatus.cancelled),
        );
        expect(
          updatedState.alerts.firstWhere((a) => a.id == alert3.id).status,
          equals(AlertStatus.resolved),
        );
      });
    });

    group('Alert Management', () {
      test('addAlert adds new alert to the list', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final initialCount = initialState.alerts.length;

        final newAlert = Alert(
          id: '999',
          title: 'New Alert',
          description: 'Test Alert',
          type: AlertType.security,
          severity: AlertSeverity.high,
          status: AlertStatus.active,
          createdAt:
              DateTime.now(), // Will use DateTime.now() in actual implementation
        );

        // Act
        notifier.addAlert(newAlert);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        expect(updatedState.alerts.length, equals(initialCount + 1));
        expect(updatedState.alerts.any((a) => a.id == newAlert.id), isTrue);
      });

      test('addAlert prepends new alert (newest first)', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final newAlert = Alert(
          id: '999',
          title: 'New Alert',
          description: 'Test Alert',
          type: AlertType.security,
          severity: AlertSeverity.high,
          status: AlertStatus.active,
          createdAt: DateTime.now(),
        );

        // Act
        notifier.addAlert(newAlert);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        expect(updatedState.alerts.first.id, equals(newAlert.id));
      });

      test('removeAlert removes specific alert from list', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToRemove = initialState.alerts.first;
        final initialCount = initialState.alerts.length;

        // Act
        notifier.removeAlert(alertToRemove.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        expect(updatedState.alerts.length, equals(initialCount - 1));
        expect(
          updatedState.alerts.any((a) => a.id == alertToRemove.id),
          isFalse,
        );
      });

      test('removeAlert preserves other alerts', () {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alertToRemove = initialState.alerts.first;
        final otherAlerts = initialState.alerts
            .where((a) => a.id != alertToRemove.id)
            .toList();

        // Act
        notifier.removeAlert(alertToRemove.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        for (final otherAlert in otherAlerts) {
          expect(updatedState.alerts.any((a) => a.id == otherAlert.id), isTrue);
        }
      });
    });

    group('Refresh Operations', () {
      test('refreshAlerts reloads alert data', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);

        // Act
        await notifier.refreshAlerts();

        // Assert
        final state = container.read(alertNotifierProvider);
        expect(state.alerts, isNotEmpty);
        expect(state.isLoading, isFalse);
      });

      test('refreshAlerts maintains alert count', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final initialCount = initialState.alerts.length;

        // Act
        await notifier.refreshAlerts();

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        expect(updatedState.alerts.length, equals(initialCount));
      });
    });

    group('Complete User Scenarios', () {
      test('user can view urgent alerts and acknowledge them', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final state = container.read(alertNotifierProvider);

        // Act - Get urgent alerts
        final urgentAlerts = state.urgentAlerts;
        expect(urgentAlerts.isNotEmpty, isTrue);

        // Acknowledge first urgent alert
        final alertToAck = urgentAlerts.first;
        await notifier.acknowledgeAlert(alertToAck.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        final acknowledgedAlert = updatedState.alerts.firstWhere(
          (a) => a.id == alertToAck.id,
        );
        expect(acknowledgedAlert.status, equals(AlertStatus.acknowledged));
      });

      test('user can filter alerts by type and resolve them', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);

        // Act - Filter by medical type
        final medicalAlerts = notifier.getAlertsByType(AlertType.medical);
        expect(medicalAlerts.isNotEmpty, isTrue);

        // Resolve first medical alert
        final alertToResolve = medicalAlerts.first;
        await notifier.resolveAlert(alertToResolve.id);

        // Assert
        final updatedState = container.read(alertNotifierProvider);
        final resolvedAlert = updatedState.alerts.firstWhere(
          (a) => a.id == alertToResolve.id,
        );
        expect(resolvedAlert.status, equals(AlertStatus.resolved));
      });

      test('state persists across multiple operations', () async {
        // Arrange
        final notifier = container.read(alertNotifierProvider.notifier);
        final initialState = container.read(alertNotifierProvider);
        final alert1 = initialState.alerts[0];
        final alert2 = initialState.alerts[1];

        // Act - Multiple operations
        await notifier.acknowledgeAlert(alert1.id);
        final newAlert = Alert(
          id: '888',
          title: 'New Emergency',
          description: 'Critical Alert',
          type: AlertType.emergency,
          severity: AlertSeverity.emergency,
          status: AlertStatus.active,
          createdAt: DateTime.now(),
        );
        notifier.addAlert(newAlert);
        await notifier.resolveAlert(alert2.id);

        // Assert - All changes persisted
        final finalState = container.read(alertNotifierProvider);
        expect(
          finalState.alerts.firstWhere((a) => a.id == alert1.id).status,
          equals(AlertStatus.acknowledged),
        );
        expect(finalState.alerts.any((a) => a.id == newAlert.id), isTrue);
        expect(
          finalState.alerts.firstWhere((a) => a.id == alert2.id).status,
          equals(AlertStatus.resolved),
        );
      });
    });

    group('State Management', () {
      test('state copyWith updates only specified fields', () {
        // Arrange
        const initialState = AlertState(
          alerts: [],
          isLoading: false,
          error: null,
        );

        // Act
        final updatedState = initialState.copyWith(isLoading: true);

        // Assert
        expect(updatedState.alerts, equals(initialState.alerts));
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.error, isNull);
      });

      test('state copyWith with null error clears error', () {
        // Arrange
        const initialState = AlertState(
          alerts: [],
          isLoading: false,
          error: 'Some error',
        );

        // Act
        final updatedState = initialState.copyWith(error: null);

        // Assert
        expect(updatedState.error, isNull);
      });

      test('urgentAlerts correctly filters by isCritical', () {
        // Arrange
        final alert1 = Alert(
          id: '1',
          title: 'Critical Alert',
          description: 'Critical',
          severity: AlertSeverity.critical,
          createdAt: DateTime.now(),
        );
        final alert2 = Alert(
          id: '2',
          title: 'Medium Alert',
          description: 'Medium',
          severity: AlertSeverity.medium,
          createdAt: DateTime.now(),
        );
        final alert3 = Alert(
          id: '3',
          title: 'Emergency Alert',
          description: 'Emergency',
          severity: AlertSeverity.emergency,
          createdAt: DateTime.now(),
        );
        final state = AlertState(alerts: [alert1, alert2, alert3]);

        // Act
        final urgent = state.urgentAlerts;

        // Assert
        expect(urgent.length, equals(2));
        expect(urgent.any((a) => a.id == '1'), isTrue);
        expect(urgent.any((a) => a.id == '3'), isTrue);
        expect(urgent.any((a) => a.id == '2'), isFalse);
      });

      test('activeAlerts correctly filters by status', () {
        // Arrange
        final alert1 = Alert(
          id: '1',
          title: 'Active Alert',
          description: 'Active',
          status: AlertStatus.active,
          createdAt: DateTime.now(),
        );
        final alert2 = Alert(
          id: '2',
          title: 'Acknowledged Alert',
          description: 'Acknowledged',
          status: AlertStatus.acknowledged,
          createdAt: DateTime.now(),
        );
        final alert3 = Alert(
          id: '3',
          title: 'Resolved Alert',
          description: 'Resolved',
          status: AlertStatus.resolved,
          createdAt: DateTime.now(),
        );
        final state = AlertState(alerts: [alert1, alert2, alert3]);

        // Act
        final active = state.activeAlerts;

        // Assert
        expect(active.length, equals(1));
        expect(active.first.id, equals('1'));
      });
    });
  });
}
