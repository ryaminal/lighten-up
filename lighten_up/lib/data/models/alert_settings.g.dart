// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertSettingsImpl _$$AlertSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AlertSettingsImpl(
      id: json['id'] as String,
      workstationId: json['workstationId'] as String,
      visual: VisualSettings.fromJson(json['visual'] as Map<String, dynamic>),
      eventMappings: (json['eventMappings'] as List<dynamic>)
          .map((e) => EventMapping.fromJson(e as Map<String, dynamic>))
          .toList(),
      quietHours: json['quietHours'] == null
          ? null
          : QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>),
      isGlobalDefault: json['isGlobalDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AlertSettingsImplToJson(_$AlertSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workstationId': instance.workstationId,
      'visual': instance.visual,
      'eventMappings': instance.eventMappings,
      'quietHours': instance.quietHours,
      'isGlobalDefault': instance.isGlobalDefault,
    };

_$VisualSettingsImpl _$$VisualSettingsImplFromJson(Map<String, dynamic> json) =>
    _$VisualSettingsImpl(
      popupWindow: json['popupWindow'] as bool? ?? true,
      flashScreen: json['flashScreen'] as bool? ?? true,
      forceFocus: json['forceFocus'] as bool? ?? false,
    );

Map<String, dynamic> _$$VisualSettingsImplToJson(
  _$VisualSettingsImpl instance,
) => <String, dynamic>{
  'popupWindow': instance.popupWindow,
  'flashScreen': instance.flashScreen,
  'forceFocus': instance.forceFocus,
};

_$EventMappingImpl _$$EventMappingImplFromJson(Map<String, dynamic> json) =>
    _$EventMappingImpl(
      id: json['id'] as String,
      eventName: json['eventName'] as String,
      eventDescription: json['eventDescription'] as String,
      priority: $enumDecode(_$AlertEventPriorityEnumMap, json['priority']),
      soundId: json['soundId'] as String,
      volume: (json['volume'] as num).toInt(),
    );

Map<String, dynamic> _$$EventMappingImplToJson(_$EventMappingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventName': instance.eventName,
      'eventDescription': instance.eventDescription,
      'priority': _$AlertEventPriorityEnumMap[instance.priority]!,
      'soundId': instance.soundId,
      'volume': instance.volume,
    };

const _$AlertEventPriorityEnumMap = {
  AlertEventPriority.emergency: 'emergency',
  AlertEventPriority.urgent: 'urgent',
  AlertEventPriority.normal: 'normal',
  AlertEventPriority.low: 'low',
};

_$QuietHoursImpl _$$QuietHoursImplFromJson(Map<String, dynamic> json) =>
    _$QuietHoursImpl(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      enabled: json['enabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuietHoursImplToJson(_$QuietHoursImpl instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'enabled': instance.enabled,
    };

_$SoundOptionImpl _$$SoundOptionImplFromJson(Map<String, dynamic> json) =>
    _$SoundOptionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$$SoundOptionImplToJson(_$SoundOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
    };
