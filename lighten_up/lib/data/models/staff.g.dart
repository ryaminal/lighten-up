// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaffScheduleImpl _$$StaffScheduleImplFromJson(Map<String, dynamic> json) =>
    _$StaffScheduleImpl(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      shiftStart: DateTime.parse(json['shiftStart'] as String),
      shiftEnd: DateTime.parse(json['shiftEnd'] as String),
      shiftType:
          $enumDecodeNullable(_$ShiftTypeEnumMap, json['shiftType']) ??
          ShiftType.morning,
      status:
          $enumDecodeNullable(_$AvailabilityStatusEnumMap, json['status']) ??
          AvailabilityStatus.available,
      location: json['location'] as String?,
      department: json['department'] as String?,
      notes: json['notes'] as String?,
      breakStart: json['breakStart'] == null
          ? null
          : DateTime.parse(json['breakStart'] as String),
      breakEnd: json['breakEnd'] == null
          ? null
          : DateTime.parse(json['breakEnd'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StaffScheduleImplToJson(_$StaffScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffId': instance.staffId,
      'shiftStart': instance.shiftStart.toIso8601String(),
      'shiftEnd': instance.shiftEnd.toIso8601String(),
      'shiftType': _$ShiftTypeEnumMap[instance.shiftType]!,
      'status': _$AvailabilityStatusEnumMap[instance.status]!,
      'location': instance.location,
      'department': instance.department,
      'notes': instance.notes,
      'breakStart': instance.breakStart?.toIso8601String(),
      'breakEnd': instance.breakEnd?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ShiftTypeEnumMap = {
  ShiftType.morning: 'morning',
  ShiftType.afternoon: 'afternoon',
  ShiftType.night: 'night',
  ShiftType.rotating: 'rotating',
};

const _$AvailabilityStatusEnumMap = {
  AvailabilityStatus.available: 'available',
  AvailabilityStatus.busy: 'busy',
  AvailabilityStatus.onBreak: 'break',
  AvailabilityStatus.inMeeting: 'meeting',
  AvailabilityStatus.offDuty: 'off_duty',
};

_$StaffMemberImpl _$$StaffMemberImplFromJson(
  Map<String, dynamic> json,
) => _$StaffMemberImpl(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  departments:
      (json['departments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  specializations:
      (json['specializations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  currentSchedule: json['currentSchedule'] == null
      ? null
      : StaffSchedule.fromJson(json['currentSchedule'] as Map<String, dynamic>),
  currentStatus:
      $enumDecodeNullable(_$AvailabilityStatusEnumMap, json['currentStatus']) ??
      AvailabilityStatus.available,
  currentLocation: json['currentLocation'] as String?,
  patientCount: (json['patientCount'] as num?)?.toInt(),
  lastStatusUpdate: json['lastStatusUpdate'] == null
      ? null
      : DateTime.parse(json['lastStatusUpdate'] as String),
);

Map<String, dynamic> _$$StaffMemberImplToJson(_$StaffMemberImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'departments': instance.departments,
      'specializations': instance.specializations,
      'certifications': instance.certifications,
      'currentSchedule': instance.currentSchedule,
      'currentStatus': _$AvailabilityStatusEnumMap[instance.currentStatus]!,
      'currentLocation': instance.currentLocation,
      'patientCount': instance.patientCount,
      'lastStatusUpdate': instance.lastStatusUpdate?.toIso8601String(),
    };

_$StaffActivityImpl _$$StaffActivityImplFromJson(Map<String, dynamic> json) =>
    _$StaffActivityImpl(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      activityType: json['activityType'] as String,
      description: json['description'] as String,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      location: json['location'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StaffActivityImplToJson(_$StaffActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffId': instance.staffId,
      'activityType': instance.activityType,
      'description': instance.description,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'location': instance.location,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$UpdateAvailabilityRequestImpl _$$UpdateAvailabilityRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateAvailabilityRequestImpl(
  staffId: json['staffId'] as String,
  status: $enumDecode(_$AvailabilityStatusEnumMap, json['status']),
  location: json['location'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$UpdateAvailabilityRequestImplToJson(
  _$UpdateAvailabilityRequestImpl instance,
) => <String, dynamic>{
  'staffId': instance.staffId,
  'status': _$AvailabilityStatusEnumMap[instance.status]!,
  'location': instance.location,
  'notes': instance.notes,
};
