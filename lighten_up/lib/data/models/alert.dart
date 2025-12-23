import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

/// Alert severity level
enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
  @JsonValue('emergency')
  emergency,
}

/// Alert status
enum AlertStatus {
  @JsonValue('active')
  active,
  @JsonValue('acknowledged')
  acknowledged,
  @JsonValue('resolved')
  resolved,
  @JsonValue('cancelled')
  cancelled,
}

/// Alert type/category
enum AlertType {
  @JsonValue('medical')
  medical,
  @JsonValue('emergency')
  emergency,
  @JsonValue('medication')
  medication,
  @JsonValue('vitals')
  vitals,
  @JsonValue('appointment')
  appointment,
  @JsonValue('system')
  system,
  @JsonValue('security')
  security,
}

/// Alert model for urgent notifications
@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String title,
    required String description,
    @Default(AlertType.system) AlertType type,
    @Default(AlertSeverity.medium) AlertSeverity severity,
    @Default(AlertStatus.active) AlertStatus status,
    String? patientId,
    String? patientName,
    String? roomNumber,
    String? location,
    String? assignedToId,
    String? assignedToName,
    String? acknowledgedById,
    String? acknowledgedByName,
    DateTime? acknowledgedAt,
    String? resolvedById,
    String? resolvedByName,
    DateTime? resolvedAt,
    String? notes,
    Map<String, dynamic>? metadata,
    @Default([]) List<String> notifiedUserIds,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Alert;

  const Alert._();

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);

  /// Check if alert is critical or emergency
  bool get isCritical =>
      severity == AlertSeverity.critical || severity == AlertSeverity.emergency;

  /// Check if alert is active
  bool get isActive => status == AlertStatus.active;

  /// Check if alert is acknowledged
  bool get isAcknowledged =>
      status == AlertStatus.acknowledged || status == AlertStatus.resolved;

  /// Check if alert is resolved
  bool get isResolved => status == AlertStatus.resolved;

  /// Get severity color (for UI)
  String get severityColorHex {
    switch (severity) {
      case AlertSeverity.low:
        return '#10B981'; // Green
      case AlertSeverity.medium:
        return '#F59E0B'; // Amber
      case AlertSeverity.high:
        return '#EF4444'; // Red
      case AlertSeverity.critical:
        return '#DC2626'; // Dark red
      case AlertSeverity.emergency:
        return '#991B1B'; // Darkest red
    }
  }

  /// Get severity display name
  String get severityDisplayName {
    switch (severity) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.emergency:
        return 'Emergency';
    }
  }

  /// Get alert type display name
  String get typeDisplayName {
    switch (type) {
      case AlertType.medical:
        return 'Medical';
      case AlertType.emergency:
        return 'Emergency';
      case AlertType.medication:
        return 'Medication';
      case AlertType.vitals:
        return 'Vitals';
      case AlertType.appointment:
        return 'Appointment';
      case AlertType.system:
        return 'System';
      case AlertType.security:
        return 'Security';
    }
  }

  /// Duration since created
  Duration get age => DateTime.now().difference(createdAt);

  /// Time ago display
  String get timeAgo {
    final difference = age;

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }
}

/// Alert settings/configuration
@freezed
class AlertSettings with _$AlertSettings {
  const factory AlertSettings({
    required String userId,
    @Default(true) bool enabled,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(true) bool criticalAlertsEnabled,
    @Default(true) bool emergencyAlertsEnabled,
    @Default(true) bool medicalAlertsEnabled,
    @Default(true) bool medicationAlertsEnabled,
    @Default(true) bool vitalsAlertsEnabled,
    @Default(5) int autoAcknowledgeMinutes,
    String? customSoundUrl,
    DateTime? updatedAt,
  }) = _AlertSettings;

  factory AlertSettings.fromJson(Map<String, dynamic> json) =>
      _$AlertSettingsFromJson(json);
}

/// Acknowledge alert request
@freezed
class AcknowledgeAlertRequest with _$AcknowledgeAlertRequest {
  const factory AcknowledgeAlertRequest({
    required String alertId,
    required String userId,
    String? notes,
  }) = _AcknowledgeAlertRequest;

  factory AcknowledgeAlertRequest.fromJson(Map<String, dynamic> json) =>
      _$AcknowledgeAlertRequestFromJson(json);
}

/// Resolve alert request
@freezed
class ResolveAlertRequest with _$ResolveAlertRequest {
  const factory ResolveAlertRequest({
    required String alertId,
    required String userId,
    String? notes,
    String? resolution,
  }) = _ResolveAlertRequest;

  factory ResolveAlertRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveAlertRequestFromJson(json);
}
