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
    required String soundId,
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
