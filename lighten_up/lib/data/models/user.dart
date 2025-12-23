import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User role in the system
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('doctor')
  doctor,
  @JsonValue('nurse')
  nurse,
  @JsonValue('staff')
  staff,
  @JsonValue('receptionist')
  receptionist,
}

/// User online status
enum UserStatus {
  @JsonValue('online')
  online,
  @JsonValue('offline')
  offline,
  @JsonValue('away')
  away,
  @JsonValue('busy')
  busy,
}

/// User data model
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    @Default(UserStatus.offline) UserStatus status,
    String? avatarUrl,
    String? phoneNumber,
    String? department,
    String? title,
    @Default(false) bool isActive,
    @Default(false) bool isVerified,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Full name helper
  String get fullName => '$firstName $lastName';

  /// Initials helper
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Check if user is online
  bool get isOnline => status == UserStatus.online;

  /// Check if user is available (online or away)
  bool get isAvailable =>
      status == UserStatus.online || status == UserStatus.away;

  /// Role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.staff:
        return 'Staff';
      case UserRole.receptionist:
        return 'Receptionist';
    }
  }
}

/// Authentication response model
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required User user,
    @Default(3600) int expiresIn,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Login request model
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (deviceId != null) 'device_id': deviceId,
    if (deviceName != null) 'device_name': deviceName,
  };
}

/// PIN verification request
@freezed
class PinRequest with _$PinRequest {
  const factory PinRequest({required String userId, required String pin}) =
      _PinRequest;

  factory PinRequest.fromJson(Map<String, dynamic> json) =>
      _$PinRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {'user_id': userId, 'pin': pin};
}
