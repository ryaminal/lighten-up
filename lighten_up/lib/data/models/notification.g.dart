// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationImpl _$$NotificationImplFromJson(Map<String, dynamic> json) =>
    _$NotificationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.system,
      priority:
          $enumDecodeNullable(
            _$NotificationPriorityEnumMap,
            json['priority'],
          ) ??
          NotificationPriority.normal,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      actionType: json['actionType'] as String?,
      actionData: json['actionData'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationImplToJson(_$NotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'isRead': instance.isRead,
      'actionUrl': instance.actionUrl,
      'actionType': instance.actionType,
      'actionData': instance.actionData,
      'imageUrl': instance.imageUrl,
      'iconUrl': instance.iconUrl,
      'readAt': instance.readAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.message: 'message',
  NotificationType.alert: 'alert',
  NotificationType.appointment: 'appointment',
  NotificationType.system: 'system',
  NotificationType.reminder: 'reminder',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSettingsImpl(
  userId: json['userId'] as String,
  enabled: json['enabled'] as bool? ?? true,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  messageNotifications: json['messageNotifications'] as bool? ?? true,
  alertNotifications: json['alertNotifications'] as bool? ?? true,
  appointmentNotifications: json['appointmentNotifications'] as bool? ?? true,
  systemNotifications: json['systemNotifications'] as bool? ?? true,
  reminderNotifications: json['reminderNotifications'] as bool? ?? true,
  quietHoursStart: json['quietHoursStart'] as String?,
  quietHoursEnd: json['quietHoursEnd'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$NotificationSettingsImplToJson(
  _$NotificationSettingsImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'enabled': instance.enabled,
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
  'messageNotifications': instance.messageNotifications,
  'alertNotifications': instance.alertNotifications,
  'appointmentNotifications': instance.appointmentNotifications,
  'systemNotifications': instance.systemNotifications,
  'reminderNotifications': instance.reminderNotifications,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
