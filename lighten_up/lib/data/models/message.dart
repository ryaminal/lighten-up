import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lighten_up/core/utils/extensions.dart';
import 'package:lighten_up/data/models/user.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Message priority level
enum MessagePriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Message status
enum MessageStatus {
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

/// Message type
enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('system')
  system,
}

/// Message model for chat/communication
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String threadId,
    required String senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? recipientId,
    String? recipientName,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessagePriority.normal) MessagePriority priority,
    @Default(MessageStatus.sent) MessageStatus status,
    @Default(false) bool isRead,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    DateTime? readAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Message;

  const Message._();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Check if message is from current user
  bool isFromUser(String userId) => senderId == userId;

  /// Check if message is urgent
  bool get isUrgent => priority == MessagePriority.urgent;

  /// Check if message is high priority
  bool get isHighPriority =>
      priority == MessagePriority.high || priority == MessagePriority.urgent;

  /// Get display time (e.g., "10:30 AM")
  String get timeDisplay {
    final now = DateTime.now();
    final messageDate = createdAt;

    if (now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day) {
      // Today - show time only
      return messageDate.to24HourString();
    } else if (now.difference(messageDate).inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[messageDate.weekday - 1];
    } else {
      // Older - show date
      return '${messageDate.month}/${messageDate.day}/${messageDate.year}';
    }
  }

  /// Has file attachment
  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;
}

/// Message thread/conversation
@freezed
class MessageThread with _$MessageThread {
  const factory MessageThread({
    required String id,
    required String title,
    @Default([]) List<String> participantIds,
    @Default([]) List<User> participants,
    Message? lastMessage,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isPinned,
    DateTime? lastActivityAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _MessageThread;

  const MessageThread._();

  factory MessageThread.fromJson(Map<String, dynamic> json) =>
      _$MessageThreadFromJson(json);

  /// Has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Get other participant names (exclude current user)
  String getOtherParticipantsNames(String currentUserId) {
    final others = participants.where((p) => p.id != currentUserId).toList();
    if (others.isEmpty) return 'You';
    if (others.length == 1) return others.first.fullName;
    if (others.length == 2) {
      return '${others[0].fullName}, ${others[1].fullName}';
    }
    return '${others[0].fullName}, ${others[1].fullName} +${others.length - 2}';
  }
}

/// Send message request
@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String threadId,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessagePriority.normal) MessagePriority priority,
    String? recipientId,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}
