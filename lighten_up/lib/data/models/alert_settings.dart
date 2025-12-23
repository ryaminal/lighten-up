import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_settings.freezed.dart';
part 'alert_settings.g.dart';

@freezed
class AlertSettings with _$AlertSettings {
  const factory AlertSettings({
    required String id,
    required String workstationId,
    required VisualSettings visual,
    required List<EventMapping> eventMappings,
    required QuietHours? quietHours,
    @Default(false) bool isGlobalDefault,
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
    required String id,
    required String eventName,
    required String eventDescription,
    required AlertEventPriority priority,
    required SoundType soundType,
    required int volume, // 0-100
  }) = _EventMapping;

  factory EventMapping.fromJson(Map<String, dynamic> json) =>
      _$EventMappingFromJson(json);
}

@freezed
class QuietHours with _$QuietHours {
  const factory QuietHours({
    required String startTime, // HH:mm format
    required String endTime, // HH:mm format
    @Default(false) bool enabled,
  }) = _QuietHours;

  factory QuietHours.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursFromJson(json);
}

enum AlertEventPriority {
  @JsonValue('emergency')
  emergency,
  @JsonValue('urgent')
  urgent,
  @JsonValue('normal')
  normal,
  @JsonValue('low')
  low,
}

/// Sound type for event notifications
enum SoundType {
  @JsonValue('urgent_siren')
  urgentSiren,
  @JsonValue('soft_chime')
  softChime,
  @JsonValue('ding_dong')
  dingDong,
  @JsonValue('digital')
  digital,
  @JsonValue('sonar')
  sonar,
  @JsonValue('none')
  none;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case SoundType.urgentSiren:
        return 'Urgent Siren';
      case SoundType.softChime:
        return 'Soft Chime';
      case SoundType.dingDong:
        return 'Ding Dong';
      case SoundType.digital:
        return 'Digital';
      case SoundType.sonar:
        return 'Sonar';
      case SoundType.none:
        return 'None';
    }
  }

  /// Parse from string sound ID
  static SoundType? fromString(String? soundId) {
    if (soundId == null) return null;
    switch (soundId.toLowerCase().replaceAll(' ', '_')) {
      case 'urgent_siren':
      case 'urgentsiren':
        return SoundType.urgentSiren;
      case 'soft_chime':
      case 'softchime':
        return SoundType.softChime;
      case 'ding_dong':
      case 'dingdong':
        return SoundType.dingDong;
      case 'digital':
        return SoundType.digital;
      case 'sonar':
        return SoundType.sonar;
      case 'none':
        return SoundType.none;
      default:
        return null;
    }
  }
}

@freezed
class SoundOption with _$SoundOption {
  const factory SoundOption({
    required String id,
    required String name,
    required String icon,
  }) = _SoundOption;

  factory SoundOption.fromJson(Map<String, dynamic> json) =>
      _$SoundOptionFromJson(json);
}
