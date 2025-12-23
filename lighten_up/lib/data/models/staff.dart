import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lighten_up/data/models/user.dart';

part 'staff.freezed.dart';
part 'staff.g.dart';

/// Staff availability status
enum AvailabilityStatus {
  @JsonValue('available')
  available,
  @JsonValue('busy')
  busy,
  @JsonValue('break')
  onBreak,
  @JsonValue('meeting')
  inMeeting,
  @JsonValue('off_duty')
  offDuty,
}

/// Staff shift type
enum ShiftType {
  @JsonValue('morning')
  morning,
  @JsonValue('afternoon')
  afternoon,
  @JsonValue('night')
  night,
  @JsonValue('rotating')
  rotating,
}

/// Staff schedule/shift model
@freezed
class StaffSchedule with _$StaffSchedule {
  const factory StaffSchedule({
    required String id,
    required String staffId,
    required DateTime shiftStart,
    required DateTime shiftEnd,
    @Default(ShiftType.morning) ShiftType shiftType,
    @Default(AvailabilityStatus.available) AvailabilityStatus status,
    String? location,
    String? department,
    String? notes,
    DateTime? breakStart,
    DateTime? breakEnd,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _StaffSchedule;

  const StaffSchedule._();

  factory StaffSchedule.fromJson(Map<String, dynamic> json) =>
      _$StaffScheduleFromJson(json);

  /// Check if currently on shift
  bool get isOnShift {
    final now = DateTime.now();
    return now.isAfter(shiftStart) && now.isBefore(shiftEnd);
  }

  /// Check if on break
  bool get isOnBreak {
    if (breakStart == null || breakEnd == null) return false;
    final now = DateTime.now();
    return now.isAfter(breakStart!) && now.isBefore(breakEnd!);
  }

  /// Check if available
  bool get isAvailable => status == AvailabilityStatus.available && isOnShift;

  /// Shift duration in hours
  double get shiftDurationHours {
    return shiftEnd.difference(shiftStart).inMinutes / 60.0;
  }

  /// Display shift time range (e.g., "8:00 AM - 4:00 PM")
  String get shiftTimeDisplay {
    final startHour = shiftStart.hour;
    final startMin = shiftStart.minute.toString().padLeft(2, '0');
    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final displayStartHour = startHour > 12 ? startHour - 12 : startHour;

    final endHour = shiftEnd.hour;
    final endMin = shiftEnd.minute.toString().padLeft(2, '0');
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final displayEndHour = endHour > 12 ? endHour - 12 : endHour;

    return '$displayStartHour:$startMin $startPeriod - $displayEndHour:$endMin $endPeriod';
  }

  /// Shift type display name
  String get shiftTypeDisplayName {
    switch (shiftType) {
      case ShiftType.morning:
        return 'Morning';
      case ShiftType.afternoon:
        return 'Afternoon';
      case ShiftType.night:
        return 'Night';
      case ShiftType.rotating:
        return 'Rotating';
    }
  }

  /// Status display name
  String get statusDisplayName {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.onBreak:
        return 'On Break';
      case AvailabilityStatus.inMeeting:
        return 'In Meeting';
      case AvailabilityStatus.offDuty:
        return 'Off Duty';
    }
  }
}

/// Staff member with schedule and extended info
@freezed
class StaffMember with _$StaffMember {
  const factory StaffMember({
    required User user,
    @Default([]) List<String> departments,
    @Default([]) List<String> specializations,
    @Default([]) List<String> certifications,
    StaffSchedule? currentSchedule,
    @Default(AvailabilityStatus.available) AvailabilityStatus currentStatus,
    String? currentLocation,
    int? patientCount,
    DateTime? lastStatusUpdate,
  }) = _StaffMember;

  const StaffMember._();

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);

  /// User ID shortcut
  String get id => user.id;

  /// Full name shortcut
  String get fullName => user.fullName;

  /// Role shortcut
  UserRole get role => user.role;

  /// Check if currently available
  bool get isAvailable =>
      currentStatus == AvailabilityStatus.available &&
      (currentSchedule?.isOnShift ?? false);

  /// Check if on shift
  bool get isOnShift => currentSchedule?.isOnShift ?? false;

  /// Check if busy
  bool get isBusy =>
      currentStatus == AvailabilityStatus.busy || (patientCount ?? 0) > 5;
}

/// Staff activity/task model
@freezed
class StaffActivity with _$StaffActivity {
  const factory StaffActivity({
    required String id,
    required String staffId,
    required String activityType,
    required String description,
    String? patientId,
    String? patientName,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    @Default(false) bool isCompleted,
    String? notes,
    required DateTime createdAt,
  }) = _StaffActivity;

  factory StaffActivity.fromJson(Map<String, dynamic> json) =>
      _$StaffActivityFromJson(json);
}

/// Update staff availability request
@freezed
class UpdateAvailabilityRequest with _$UpdateAvailabilityRequest {
  const factory UpdateAvailabilityRequest({
    required String staffId,
    required AvailabilityStatus status,
    String? location,
    String? notes,
  }) = _UpdateAvailabilityRequest;

  factory UpdateAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvailabilityRequestFromJson(json);
}
