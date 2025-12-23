import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification type
enum NotificationType {
  @JsonValue('message')
  message,
  @JsonValue('alert')
  alert,
  @JsonValue('appointment')
  appointment,
  @JsonValue('system')
  system,
  @JsonValue('reminder')
  reminder,
}

/// Notification priority
enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Notification model
@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String title,
    required String body,
    @Default(NotificationType.system) NotificationType type,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    @Default(false) bool isRead,
    String? actionUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? imageUrl,
    String? iconUrl,
    DateTime? readAt,
    DateTime? expiresAt,
    required DateTime createdAt,
  }) = _Notification;

  const Notification._();

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  /// Check if notification is urgent
  bool get isUrgent => priority == NotificationPriority.urgent;

  /// Check if notification is high priority
  bool get isHighPriority =>
      priority == NotificationPriority.high ||
      priority == NotificationPriority.urgent;

  /// Check if notification is expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Has action
  bool get hasAction => actionUrl != null || actionType != null;

  /// Time ago display (e.g., "5 minutes ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }
}

/// Notification settings
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    required String userId,
    @Default(true) bool enabled,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(true) bool messageNotifications,
    @Default(true) bool alertNotifications,
    @Default(true) bool appointmentNotifications,
    @Default(true) bool systemNotifications,
    @Default(true) bool reminderNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? updatedAt,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}
