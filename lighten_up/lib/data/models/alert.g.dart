// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertImpl _$$AlertImplFromJson(Map<String, dynamic> json) => _$AlertImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type:
      $enumDecodeNullable(_$AlertTypeEnumMap, json['type']) ?? AlertType.system,
  severity:
      $enumDecodeNullable(_$AlertSeverityEnumMap, json['severity']) ??
      AlertSeverity.medium,
  status:
      $enumDecodeNullable(_$AlertStatusEnumMap, json['status']) ??
      AlertStatus.active,
  patientId: json['patientId'] as String?,
  patientName: json['patientName'] as String?,
  roomNumber: json['roomNumber'] as String?,
  location: json['location'] as String?,
  assignedToId: json['assignedToId'] as String?,
  assignedToName: json['assignedToName'] as String?,
  acknowledgedById: json['acknowledgedById'] as String?,
  acknowledgedByName: json['acknowledgedByName'] as String?,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  resolvedById: json['resolvedById'] as String?,
  resolvedByName: json['resolvedByName'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  notifiedUserIds:
      (json['notifiedUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$AlertImplToJson(_$AlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'status': _$AlertStatusEnumMap[instance.status]!,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'roomNumber': instance.roomNumber,
      'location': instance.location,
      'assignedToId': instance.assignedToId,
      'assignedToName': instance.assignedToName,
      'acknowledgedById': instance.acknowledgedById,
      'acknowledgedByName': instance.acknowledgedByName,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'resolvedById': instance.resolvedById,
      'resolvedByName': instance.resolvedByName,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'notifiedUserIds': instance.notifiedUserIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.medical: 'medical',
  AlertType.emergency: 'emergency',
  AlertType.medication: 'medication',
  AlertType.vitals: 'vitals',
  AlertType.appointment: 'appointment',
  AlertType.system: 'system',
  AlertType.security: 'security',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
  AlertSeverity.emergency: 'emergency',
};

const _$AlertStatusEnumMap = {
  AlertStatus.active: 'active',
  AlertStatus.acknowledged: 'acknowledged',
  AlertStatus.resolved: 'resolved',
  AlertStatus.cancelled: 'cancelled',
};

_$AlertSettingsImpl _$$AlertSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AlertSettingsImpl(
      userId: json['userId'] as String,
      enabled: json['enabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      criticalAlertsEnabled: json['criticalAlertsEnabled'] as bool? ?? true,
      emergencyAlertsEnabled: json['emergencyAlertsEnabled'] as bool? ?? true,
      medicalAlertsEnabled: json['medicalAlertsEnabled'] as bool? ?? true,
      medicationAlertsEnabled: json['medicationAlertsEnabled'] as bool? ?? true,
      vitalsAlertsEnabled: json['vitalsAlertsEnabled'] as bool? ?? true,
      autoAcknowledgeMinutes:
          (json['autoAcknowledgeMinutes'] as num?)?.toInt() ?? 5,
      customSoundUrl: json['customSoundUrl'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AlertSettingsImplToJson(_$AlertSettingsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'enabled': instance.enabled,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'criticalAlertsEnabled': instance.criticalAlertsEnabled,
      'emergencyAlertsEnabled': instance.emergencyAlertsEnabled,
      'medicalAlertsEnabled': instance.medicalAlertsEnabled,
      'medicationAlertsEnabled': instance.medicationAlertsEnabled,
      'vitalsAlertsEnabled': instance.vitalsAlertsEnabled,
      'autoAcknowledgeMinutes': instance.autoAcknowledgeMinutes,
      'customSoundUrl': instance.customSoundUrl,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$AcknowledgeAlertRequestImpl _$$AcknowledgeAlertRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AcknowledgeAlertRequestImpl(
  alertId: json['alertId'] as String,
  userId: json['userId'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$AcknowledgeAlertRequestImplToJson(
  _$AcknowledgeAlertRequestImpl instance,
) => <String, dynamic>{
  'alertId': instance.alertId,
  'userId': instance.userId,
  'notes': instance.notes,
};

_$ResolveAlertRequestImpl _$$ResolveAlertRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ResolveAlertRequestImpl(
  alertId: json['alertId'] as String,
  userId: json['userId'] as String,
  notes: json['notes'] as String?,
  resolution: json['resolution'] as String?,
);

Map<String, dynamic> _$$ResolveAlertRequestImplToJson(
  _$ResolveAlertRequestImpl instance,
) => <String, dynamic>{
  'alertId': instance.alertId,
  'userId': instance.userId,
  'notes': instance.notes,
  'resolution': instance.resolution,
};
