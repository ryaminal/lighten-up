// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workstation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkstationImpl _$$WorkstationImplFromJson(Map<String, dynamic> json) =>
    _$WorkstationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      zone: json['zone'] as String,
      status: $enumDecode(_$WorkstationStatusEnumMap, json['status']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$WorkstationImplToJson(_$WorkstationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'zone': instance.zone,
      'status': _$WorkstationStatusEnumMap[instance.status]!,
      'description': instance.description,
    };

const _$WorkstationStatusEnumMap = {
  WorkstationStatus.active: 'active',
  WorkstationStatus.offline: 'offline',
  WorkstationStatus.maintenance: 'maintenance',
};
