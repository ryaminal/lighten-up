// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      threadId: json['threadId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      recipientId: json['recipientId'] as String?,
      recipientName: json['recipientName'] as String?,
      content: json['content'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      priority:
          $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']) ??
          MessagePriority.normal,
      status:
          $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sent,
      isRead: json['isRead'] as bool? ?? false,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'recipientId': instance.recipientId,
      'recipientName': instance.recipientName,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'priority': _$MessagePriorityEnumMap[instance.priority]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'isRead': instance.isRead,
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.system: 'system',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.low: 'low',
  MessagePriority.normal: 'normal',
  MessagePriority.high: 'high',
  MessagePriority.urgent: 'urgent',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};

_$MessageThreadImpl _$$MessageThreadImplFromJson(Map<String, dynamic> json) =>
    _$MessageThreadImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MessageThreadImplToJson(_$MessageThreadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'participantIds': instance.participantIds,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'isMuted': instance.isMuted,
      'isPinned': instance.isPinned,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$SendMessageRequestImpl _$$SendMessageRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SendMessageRequestImpl(
  threadId: json['threadId'] as String,
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  priority:
      $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']) ??
      MessagePriority.normal,
  recipientId: json['recipientId'] as String?,
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$SendMessageRequestImplToJson(
  _$SendMessageRequestImpl instance,
) => <String, dynamic>{
  'threadId': instance.threadId,
  'content': instance.content,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'priority': _$MessagePriorityEnumMap[instance.priority]!,
  'recipientId': instance.recipientId,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'fileSize': instance.fileSize,
  'metadata': instance.metadata,
};
