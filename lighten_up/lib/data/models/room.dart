import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lighten_up/core/utils/extensions.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// Room status
enum RoomStatus {
  @JsonValue('available')
  available,
  @JsonValue('occupied')
  occupied,
  @JsonValue('cleaning')
  cleaning,
  @JsonValue('maintenance')
  maintenance,
}

/// Light status for room alert lights
enum LightStatus {
  @JsonValue('inactive')
  inactive,
  @JsonValue('active')
  active,
  @JsonValue('acknowledged')
  acknowledged,
}

/// Light type/category
enum LightType {
  @JsonValue('doctor')
  doctor,
  @JsonValue('assistant')
  assistant,
  @JsonValue('hygiene')
  hygiene,
  @JsonValue('emergency')
  emergency,
  @JsonValue('custom')
  custom,
}

/// Light priority level
enum LightPriority {
  @JsonValue('normal')
  normal,
  @JsonValue('urgent')
  urgent,
  @JsonValue('emergency')
  emergency,
}

/// Zone type for filtering and categorization
enum ZoneType {
  @JsonValue('doctors_wing')
  doctorsWing,
  @JsonValue('hygiene_wing')
  hygieneWing,
  @JsonValue('front_desk')
  frontDesk;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case ZoneType.doctorsWing:
        return "Doctor's Wing";
      case ZoneType.hygieneWing:
        return 'Hygiene Wing';
      case ZoneType.frontDesk:
        return 'Front Desk';
    }
  }

  /// Parse from string zone value
  static ZoneType? fromString(String? zone) {
    if (zone == null) return null;
    switch (zone.toLowerCase().replaceAll(' ', '_').replaceAll("'", '')) {
      case 'doctors_wing':
      case 'doctor_wing':
        return ZoneType.doctorsWing;
      case 'hygiene_wing':
        return ZoneType.hygieneWing;
      case 'front_desk':
        return ZoneType.frontDesk;
      default:
        return null;
    }
  }
}

/// Room light model
@freezed
class RoomLight with _$RoomLight {
  const factory RoomLight({
    required String id,
    required LightType type,
    required String label,
    @Default(LightStatus.inactive) LightStatus status,
    @Default(LightPriority.normal) LightPriority priority,
    String? activatedBy,
    @JsonKey(name: 'activated_by_name') String? activatedByName,
    DateTime? activatedAt,
    String? notes,
    String? iconName,
  }) = _RoomLight;

  const RoomLight._();

  factory RoomLight.fromJson(Map<String, dynamic> json) =>
      _$RoomLightFromJson(json);

  /// Check if light is active
  bool get isActive => status == LightStatus.active;

  /// Check if light is urgent or emergency
  bool get isCritical =>
      priority == LightPriority.urgent || priority == LightPriority.emergency;

  /// Get duration since activation
  Duration? get activeDuration {
    if (activatedAt == null) return null;
    return DateTime.now().difference(activatedAt!);
  }

  /// Format timer display (MM:SS)
  String get timerDisplay {
    final duration = activeDuration;
    if (duration == null) return '00:00';
    return duration.toTimerDisplay();
  }

  /// Get color for light based on priority
  String get colorHex {
    switch (priority) {
      case LightPriority.normal:
        return '#10B981'; // Green
      case LightPriority.urgent:
        return '#F59E0B'; // Amber
      case LightPriority.emergency:
        return '#EF4444'; // Red
    }
  }

  /// Get icon name for light type
  String get defaultIconName {
    switch (type) {
      case LightType.doctor:
        return 'medical_services';
      case LightType.assistant:
        return 'vaccines';
      case LightType.hygiene:
        return 'cleaning_services';
      case LightType.emergency:
        return 'emergency';
      case LightType.custom:
        return 'lightbulb';
    }
  }
}

/// Room model
@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    String? displayName,
    @Default(RoomStatus.available) RoomStatus status,
    ZoneType? zone,
    String? location,
    String? description,
    @Default([]) List<RoomLight> lights,
    String? currentPatientId,
    @JsonKey(name: 'current_patient_name') String? currentPatientName,
    String? assignedStaffId,
    @JsonKey(name: 'assigned_staff_name') String? assignedStaffName,
    int? capacity,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Room;

  const Room._();

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  /// Get display name or fallback to name
  String get displayLabel => displayName ?? name;

  /// Check if room is occupied
  bool get isOccupied => status == RoomStatus.occupied;

  /// Check if room is available
  bool get isAvailable => status == RoomStatus.available;

  /// Check if any lights are active
  bool get hasActiveLights => lights.any((light) => light.isActive);

  /// Check if any urgent lights are active
  bool get hasUrgentLights =>
      lights.any((light) => light.isActive && light.isCritical);

  /// Get count of active lights
  int get activeLightCount => lights.where((light) => light.isActive).length;

  /// Get active lights sorted by priority
  List<RoomLight> get activeLights {
    final active = lights.where((light) => light.isActive).toList();
    active.sort((a, b) {
      // Emergency first, then urgent, then normal
      final priorityOrder = {
        LightPriority.emergency: 0,
        LightPriority.urgent: 1,
        LightPriority.normal: 2,
      };
      return (priorityOrder[a.priority] ?? 2).compareTo(
        priorityOrder[b.priority] ?? 2,
      );
    });
    return active;
  }

  /// Status display name
  String get statusDisplayName {
    switch (status) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.cleaning:
        return 'Cleaning';
      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }
}

/// Room filter/zone model
@freezed
class RoomZone with _$RoomZone {
  const factory RoomZone({
    required String id,
    required String name,
    String? description,
    @Default(0) int roomCount,
  }) = _RoomZone;

  factory RoomZone.fromJson(Map<String, dynamic> json) =>
      _$RoomZoneFromJson(json);
}
