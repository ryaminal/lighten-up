# BlueNote Data Models & State Management

## State Management Strategy

### Chosen Solution: Riverpod 2.x

**Why Riverpod?**
- Compile-time safety
- No BuildContext dependency
- Easy testing and mocking
- Provider composition
- Better performance with automatic caching
- Built-in support for async operations

### Provider Types Usage

1. **Provider**: For immutable/computed values
2. **StateProvider**: For simple state (primitives, enums)
3. **StateNotifierProvider**: For complex mutable state
4. **FutureProvider**: For async data fetching
5. **StreamProvider**: For real-time data (WebSocket)

---

## Core Data Models

### 1. User Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required UserRole role,
    required String department,
    String? avatarUrl,
    required UserStatus status,
    String? currentStationId,
    @Default(false) bool isOnline,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserRole {
  admin,
  doctor,
  nurse,
  frontDesk,
  staff,
}

enum UserStatus {
  available,
  busy,
  away,
  offline,
}
```

### 2. Room Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    required String zoneId,
    required RoomType type,
    required RoomOccupancyStatus occupancyStatus,
    required List<LightStatus> lights,
    String? currentPatientId,
    String? assignedStaffId,
    DateTime? lastActivityAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

enum RoomType {
  examRoom,
  hygieneRoom,
  operatory,
  consultation,
  lab,
  frontDesk,
  triage,
}

enum RoomOccupancyStatus {
  available,
  occupied,
  cleaning,
  offline,
}

@freezed
class LightStatus with _$LightStatus {
  const factory LightStatus({
    required String id,
    required LightType type,
    required bool isActive,
    DateTime? activatedAt,
    String? activatedBy,
    String? note,
    LightUrgency? urgency,
  }) = _LightStatus;

  factory LightStatus.fromJson(Map<String, dynamic> json) =>
      _$LightStatusFromJson(json);
}

enum LightType {
  doctor,
  assistant,
  hygiene,
  anesthesia,
  phoneCall,
  emergency,
  patientReady,
  cleaning,
}

enum LightUrgency {
  routine,
  standard,
  urgent,
  emergency,
}
```

### 3. Alert Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String roomId,
    required String roomName,
    required AlertType type,
    required AlertPriority priority,
    required String message,
    required DateTime createdAt,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    @Default(false) bool isRead,
    Map<String, dynamic>? metadata,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}

enum AlertType {
  emergency,
  assistance,
  patientReady,
  roomStatus,
  system,
  broadcast,
}

enum AlertPriority {
  low,
  normal,
  high,
  critical,
}
```

### 4. Conversation & Message Models

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String participantId,
    required String participantName,
    String? participantAvatarUrl,
    required ConversationType type,
    Message? lastMessage,
    @Default(0) int unreadCount,
    @Default(false) bool isUrgent,
    @Default(false) bool isArchived,
    DateTime? lastActivityAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

enum ConversationType {
  direct,
  group,
  broadcast,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
    required DateTime sentAt,
    DateTime? readAt,
    @Default(false) bool isSentByMe,
    List<Attachment>? attachments,
    Map<String, dynamic>? metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

enum MessageType {
  text,
  image,
  file,
  system,
  quickAction,
}

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String name,
    required String url,
    required String mimeType,
    required int sizeBytes,
    String? thumbnailUrl,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}
```

### 5. Workstation & Alert Settings Models

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workstation.freezed.dart';
part 'workstation.g.dart';

@freezed
class Workstation with _$Workstation {
  const factory Workstation({
    required String id,
    required String name,
    required String zoneId,
    required String zoneName,
    required WorkstationStatus status,
    AlertSettings? alertSettings,
  }) = _Workstation;

  factory Workstation.fromJson(Map<String, dynamic> json) =>
      _$WorkstationFromJson(json);
}

enum WorkstationStatus {
  active,
  offline,
  maintenance,
}

@freezed
class AlertSettings with _$AlertSettings {
  const factory AlertSettings({
    required VisualSettings visualSettings,
    required String selectedSound,
    required List<EventMapping> eventMappings,
    QuietHours? quietHours,
  }) = _AlertSettings;

  factory AlertSettings.fromJson(Map<String, dynamic> json) =>
      _$AlertSettingsFromJson(json);
}

@freezed
class VisualSettings with _$VisualSettings {
  const factory VisualSettings({
    @Default(true) bool popupWindow,
    @Default(true) bool flashScreen,
    @Default(false) bool forceFocus,
  }) = _VisualSettings;

  factory VisualSettings.fromJson(Map<String, dynamic> json) =>
      _$VisualSettingsFromJson(json);
}

@freezed
class EventMapping with _$EventMapping {
  const factory EventMapping({
    required String eventType,
    required String soundId,
    @Default(50) int volume,
  }) = _EventMapping;

  factory EventMapping.fromJson(Map<String, dynamic> json) =>
      _$EventMappingFromJson(json);
}

@freezed
class QuietHours with _$QuietHours {
  const factory QuietHours({
    required String startTime,
    required String endTime,
    @Default(false) bool enabled,
  }) = _QuietHours;

  factory QuietHours.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursFromJson(json);
}
```

### 6. Analytics Models

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

@freezed
class DailyMetrics with _$DailyMetrics {
  const factory DailyMetrics({
    required DateTime date,
    required Duration averageResponseTime,
    required int totalAlertsActivated,
    required String slowestResponseArea,
    required double responseTimeChange,
    required int overdueAlerts,
  }) = _DailyMetrics;

  factory DailyMetrics.fromJson(Map<String, dynamic> json) =>
      _$DailyMetricsFromJson(json);
}

@freezed
class ActivityLog with _$ActivityLog {
  const factory ActivityLog({
    required String id,
    required DateTime timestamp,
    required String location,
    required String eventTag,
    required String initiatedBy,
    required String clearedBy,
    required Duration duration,
    @Default(false) bool isOverdue,
  }) = _ActivityLog;

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);
}

@freezed
class BusyHourData with _$BusyHourData {
  const factory BusyHourData({
    required int hour,
    required int activityCount,
  }) = _BusyHourData;

  factory BusyHourData.fromJson(Map<String, dynamic> json) =>
      _$BusyHourDataFromJson(json);
}

@freezed
class AlertTypeDistribution with _$AlertTypeDistribution {
  const factory AlertTypeDistribution({
    required String type,
    required int count,
    required double percentage,
  }) = _AlertTypeDistribution;

  factory AlertTypeDistribution.fromJson(Map<String, dynamic> json) =>
      _$AlertTypeDistributionFromJson(json);
}
```

---

## State Management Implementation

### Provider Examples

#### 1. Auth Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState.unauthenticated());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      // Call login use case
      final user = await ref.read(loginUseCaseProvider)(email, password);
      ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    // Call logout use case
    await ref.read(logoutUseCaseProvider)();
    ref.read(currentUserProvider.notifier).state = null;
    state = const AuthState.unauthenticated();
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
```

#### 2. Room Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Rooms list provider
final roomsProvider = StreamProvider<List<Room>>((ref) {
  return ref.watch(getRoomsUseCaseProvider)();
});

// Single room provider
final roomProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  return ref.watch(getRoomStatusUseCaseProvider)(roomId);
});

// Room filter provider
final selectedZoneProvider = StateProvider<String?>((ref) => null);

// Filtered rooms provider
final filteredRoomsProvider = Provider<List<Room>>((ref) {
  final rooms = ref.watch(roomsProvider).value ?? [];
  final selectedZone = ref.watch(selectedZoneProvider);

  if (selectedZone == null) return rooms;
  return rooms.where((room) => room.zoneId == selectedZone).toList();
});

// Activate light use case provider
final activateLightProvider = Provider((ref) {
  return ref.watch(activateLightUseCaseProvider);
});
```

#### 3. Alert Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Real-time alerts stream
final alertsStreamProvider = StreamProvider<List<Alert>>((ref) {
  return ref.watch(getAlertsUseCaseProvider)();
});

// Unread alert count
final unreadAlertCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsStreamProvider).value ?? [];
  return alerts.where((alert) => !alert.isRead).length;
});

// Acknowledge alert
final acknowledgeAlertProvider = Provider((ref) {
  return ref.watch(acknowledgeAlertUseCaseProvider);
});
```

#### 4. Chat Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Conversations list
final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  return ref.watch(getConversationsUseCaseProvider)();
});

// Active conversation
final activeConversationIdProvider = StateProvider<String?>((ref) => null);

// Messages for active conversation
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final conversationId = ref.watch(activeConversationIdProvider);
  if (conversationId == null) return Stream.value([]);
  return ref.watch(getMessagesUseCaseProvider)(conversationId);
});

// Send message
final sendMessageProvider = Provider((ref) {
  return ref.watch(sendMessageUseCaseProvider);
});

// Typing indicator
final typingIndicatorProvider = StateProvider<bool>((ref) => false);
```

#### 5. Theme Provider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // Persist to storage
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
```

---

## Data Flow Architecture

### Request Flow
```
UI Widget
  → reads Provider
    → calls Use Case
      → calls Repository
        → calls Data Source (Remote/Local)
          → returns Data
```

### Response Flow
```
Data Source
  → returns DTO/Model
    → Repository transforms to Entity
      → Use Case processes
        → Provider notifies
          → UI rebuilds
```

---

## Error Handling

### Failure Types

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverError([String? message]) = ServerFailure;
  const factory Failure.networkError() = NetworkFailure;
  const factory Failure.cacheError() = CacheFailure;
  const factory Failure.validationError(String message) = ValidationFailure;
  const factory Failure.authenticationError() = AuthenticationFailure;
  const factory Failure.permissionError() = PermissionFailure;
  const factory Failure.notFoundError() = NotFoundFailure;
}
```

### Result Type

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failure<T>;
}
```

---

## Caching Strategy

### Cache Duration by Data Type
- **User profile**: 30 minutes
- **Room statuses**: Real-time (WebSocket) + 30s fallback
- **Alert settings**: 1 hour
- **Analytics data**: 5 minutes
- **Conversations**: Real-time + cache for offline
- **Messages**: Permanent cache with sync

### Implementation

```dart
final cacheProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

class CacheManager {
  final Map<String, CachedData> _cache = {};

  T? get<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    if (cached.isExpired) {
      _cache.remove(key);
      return null;
    }

    return cached.data as T;
  }

  void set<T>(String key, T data, Duration ttl) {
    _cache[key] = CachedData(
      data: data,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void clear() => _cache.clear();
}

class CachedData {
  final dynamic data;
  final DateTime expiresAt;

  CachedData({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

---

## WebSocket State Management

```dart
final webSocketProvider = StreamProvider<WebSocketEvent>((ref) {
  final client = ref.watch(webSocketClientProvider);
  return client.stream;
});

// Handle incoming events
final webSocketListenerProvider = Provider((ref) {
  ref.listen<AsyncValue<WebSocketEvent>>(
    webSocketProvider,
    (previous, next) {
      next.whenData((event) {
        switch (event.type) {
          case WebSocketEventType.roomStatusUpdated:
            // Invalidate room cache
            ref.invalidate(roomsProvider);
            break;
          case WebSocketEventType.newAlert:
            // Invalidate alerts
            ref.invalidate(alertsStreamProvider);
            break;
          case WebSocketEventType.newMessage:
            // Invalidate messages
            ref.invalidate(messagesProvider);
            break;
        }
      });
    },
  );
});
```

---

## Next Steps

1. Generate freezed code: `flutter pub run build_runner build`
2. Implement repositories
3. Create use cases
4. Set up providers
5. Build UI with provider consumers
6. Test state management flows
