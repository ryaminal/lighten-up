import 'package:flutter/foundation.dart';
import 'package:lighten_up/data/models/alert.dart';
import 'package:lighten_up/presentation/providers/mock_alert_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alert_provider.g.dart';

/// State for alert management
class AlertState {
  final List<Alert> alerts;
  final bool isLoading;
  final String? error;

  const AlertState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
  });

  AlertState copyWith({List<Alert>? alerts, bool? isLoading, String? error}) {
    return AlertState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get urgent/critical alerts (emergency and high severity)
  List<Alert> get urgentAlerts {
    return alerts.where((alert) => alert.isCritical).toList();
  }

  /// Get non-critical alerts
  List<Alert> get roomStatusAlerts {
    return alerts.where((alert) => !alert.isCritical).toList();
  }

  /// Get active alerts only
  List<Alert> get activeAlerts {
    return alerts.where((alert) => alert.status == AlertStatus.active).toList();
  }

  /// Get count of urgent alerts
  int get urgentAlertCount => urgentAlerts.length;
}

/// Provider for managing alert data
@riverpod
class AlertNotifier extends _$AlertNotifier {
  @override
  AlertState build() {
    // Load mock data synchronously during initialization
    // This avoids async lifecycle issues with Riverpod's build() method
    // When connecting to real API, consider using AsyncNotifierProvider instead
    final alerts = MockAlertData.getAlerts();

    return AlertState(alerts: alerts, isLoading: false);
  }

  /// Load alerts from data source
  Future<void> _loadAlerts() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Replace with actual API call or WebSocket subscription
      await Future.delayed(const Duration(milliseconds: 300));

      final alerts = MockAlertData.getAlerts();

      state = state.copyWith(alerts: alerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load alerts: ${e.toString()}',
      );
    }
  }

  /// Refresh alerts data
  Future<void> refreshAlerts() async {
    await _loadAlerts();
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(String alertId) async {
    // TODO: Call API to acknowledge alert
    debugPrint('Acknowledging alert: $alertId');

    // Mock implementation - update local state
    final updatedAlerts = state.alerts.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(status: AlertStatus.acknowledged);
      }
      return alert;
    }).toList();

    state = state.copyWith(alerts: updatedAlerts);
  }

  /// Cancel an alert
  Future<void> cancelAlert(String alertId) async {
    // TODO: Call API to cancel alert
    debugPrint('Cancelling alert: $alertId');

    // Mock implementation - update local state
    final updatedAlerts = state.alerts.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(status: AlertStatus.cancelled);
      }
      return alert;
    }).toList();

    state = state.copyWith(alerts: updatedAlerts);
  }

  /// Resolve an alert
  Future<void> resolveAlert(String alertId) async {
    // TODO: Call API to resolve alert
    debugPrint('Resolving alert: $alertId');

    // Mock implementation - update local state
    final updatedAlerts = state.alerts.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(status: AlertStatus.resolved);
      }
      return alert;
    }).toList();

    state = state.copyWith(alerts: updatedAlerts);
  }

  /// Add a new alert (for testing or real-time updates)
  void addAlert(Alert alert) {
    final updatedAlerts = [alert, ...state.alerts];
    state = state.copyWith(alerts: updatedAlerts);
    debugPrint('New alert added: ${alert.title}');
  }

  /// Remove an alert from the list
  void removeAlert(String alertId) {
    final updatedAlerts = state.alerts
        .where((alert) => alert.id != alertId)
        .toList();
    state = state.copyWith(alerts: updatedAlerts);
  }

  /// Filter alerts by type
  List<Alert> getAlertsByType(AlertType type) {
    return state.alerts.where((alert) => alert.type == type).toList();
  }

  /// Filter alerts by severity
  List<Alert> getAlertsBySeverity(AlertSeverity severity) {
    return state.alerts.where((alert) => alert.severity == severity).toList();
  }
}
