// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomLightImpl _$$RoomLightImplFromJson(Map<String, dynamic> json) =>
    _$RoomLightImpl(
      id: json['id'] as String,
      type: $enumDecode(_$LightTypeEnumMap, json['type']),
      label: json['label'] as String,
      status:
          $enumDecodeNullable(_$LightStatusEnumMap, json['status']) ??
          LightStatus.inactive,
      priority:
          $enumDecodeNullable(_$LightPriorityEnumMap, json['priority']) ??
          LightPriority.normal,
      activatedBy: json['activatedBy'] as String?,
      activatedByName: json['activated_by_name'] as String?,
      activatedAt: json['activatedAt'] == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      notes: json['notes'] as String?,
      iconName: json['iconName'] as String?,
    );

Map<String, dynamic> _$$RoomLightImplToJson(_$RoomLightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$LightTypeEnumMap[instance.type]!,
      'label': instance.label,
      'status': _$LightStatusEnumMap[instance.status]!,
      'priority': _$LightPriorityEnumMap[instance.priority]!,
      'activatedBy': instance.activatedBy,
      'activated_by_name': instance.activatedByName,
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'notes': instance.notes,
      'iconName': instance.iconName,
    };

const _$LightTypeEnumMap = {
  LightType.doctor: 'doctor',
  LightType.assistant: 'assistant',
  LightType.hygiene: 'hygiene',
  LightType.emergency: 'emergency',
  LightType.custom: 'custom',
};

const _$LightStatusEnumMap = {
  LightStatus.inactive: 'inactive',
  LightStatus.active: 'active',
  LightStatus.acknowledged: 'acknowledged',
};

const _$LightPriorityEnumMap = {
  LightPriority.normal: 'normal',
  LightPriority.urgent: 'urgent',
  LightPriority.emergency: 'emergency',
};

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String?,
  status:
      $enumDecodeNullable(_$RoomStatusEnumMap, json['status']) ??
      RoomStatus.available,
  zone: json['zone'] as String?,
  location: json['location'] as String?,
  description: json['description'] as String?,
  lights:
      (json['lights'] as List<dynamic>?)
          ?.map((e) => RoomLight.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentPatientId: json['currentPatientId'] as String?,
  currentPatientName: json['current_patient_name'] as String?,
  assignedStaffId: json['assignedStaffId'] as String?,
  assignedStaffName: json['assigned_staff_name'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'status': _$RoomStatusEnumMap[instance.status]!,
      'zone': instance.zone,
      'location': instance.location,
      'description': instance.description,
      'lights': instance.lights,
      'currentPatientId': instance.currentPatientId,
      'current_patient_name': instance.currentPatientName,
      'assignedStaffId': instance.assignedStaffId,
      'assigned_staff_name': instance.assignedStaffName,
      'capacity': instance.capacity,
      'metadata': instance.metadata,
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$RoomStatusEnumMap = {
  RoomStatus.available: 'available',
  RoomStatus.occupied: 'occupied',
  RoomStatus.cleaning: 'cleaning',
  RoomStatus.maintenance: 'maintenance',
};

_$RoomZoneImpl _$$RoomZoneImplFromJson(Map<String, dynamic> json) =>
    _$RoomZoneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      roomCount: (json['roomCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RoomZoneImplToJson(_$RoomZoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'roomCount': instance.roomCount,
    };
