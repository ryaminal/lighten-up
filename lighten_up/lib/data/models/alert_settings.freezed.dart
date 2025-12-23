// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlertSettings _$AlertSettingsFromJson(Map<String, dynamic> json) {
  return _AlertSettings.fromJson(json);
}

/// @nodoc
mixin _$AlertSettings {
  String get id => throw _privateConstructorUsedError;
  String get workstationId => throw _privateConstructorUsedError;
  VisualSettings get visual => throw _privateConstructorUsedError;
  List<EventMapping> get eventMappings => throw _privateConstructorUsedError;
  QuietHours? get quietHours => throw _privateConstructorUsedError;
  bool get isGlobalDefault => throw _privateConstructorUsedError;

  /// Serializes this AlertSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertSettingsCopyWith<AlertSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertSettingsCopyWith<$Res> {
  factory $AlertSettingsCopyWith(
    AlertSettings value,
    $Res Function(AlertSettings) then,
  ) = _$AlertSettingsCopyWithImpl<$Res, AlertSettings>;
  @useResult
  $Res call({
    String id,
    String workstationId,
    VisualSettings visual,
    List<EventMapping> eventMappings,
    QuietHours? quietHours,
    bool isGlobalDefault,
  });

  $VisualSettingsCopyWith<$Res> get visual;
  $QuietHoursCopyWith<$Res>? get quietHours;
}

/// @nodoc
class _$AlertSettingsCopyWithImpl<$Res, $Val extends AlertSettings>
    implements $AlertSettingsCopyWith<$Res> {
  _$AlertSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workstationId = null,
    Object? visual = null,
    Object? eventMappings = null,
    Object? quietHours = freezed,
    Object? isGlobalDefault = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            workstationId: null == workstationId
                ? _value.workstationId
                : workstationId // ignore: cast_nullable_to_non_nullable
                      as String,
            visual: null == visual
                ? _value.visual
                : visual // ignore: cast_nullable_to_non_nullable
                      as VisualSettings,
            eventMappings: null == eventMappings
                ? _value.eventMappings
                : eventMappings // ignore: cast_nullable_to_non_nullable
                      as List<EventMapping>,
            quietHours: freezed == quietHours
                ? _value.quietHours
                : quietHours // ignore: cast_nullable_to_non_nullable
                      as QuietHours?,
            isGlobalDefault: null == isGlobalDefault
                ? _value.isGlobalDefault
                : isGlobalDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VisualSettingsCopyWith<$Res> get visual {
    return $VisualSettingsCopyWith<$Res>(_value.visual, (value) {
      return _then(_value.copyWith(visual: value) as $Val);
    });
  }

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuietHoursCopyWith<$Res>? get quietHours {
    if (_value.quietHours == null) {
      return null;
    }

    return $QuietHoursCopyWith<$Res>(_value.quietHours!, (value) {
      return _then(_value.copyWith(quietHours: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AlertSettingsImplCopyWith<$Res>
    implements $AlertSettingsCopyWith<$Res> {
  factory _$$AlertSettingsImplCopyWith(
    _$AlertSettingsImpl value,
    $Res Function(_$AlertSettingsImpl) then,
  ) = __$$AlertSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String workstationId,
    VisualSettings visual,
    List<EventMapping> eventMappings,
    QuietHours? quietHours,
    bool isGlobalDefault,
  });

  @override
  $VisualSettingsCopyWith<$Res> get visual;
  @override
  $QuietHoursCopyWith<$Res>? get quietHours;
}

/// @nodoc
class __$$AlertSettingsImplCopyWithImpl<$Res>
    extends _$AlertSettingsCopyWithImpl<$Res, _$AlertSettingsImpl>
    implements _$$AlertSettingsImplCopyWith<$Res> {
  __$$AlertSettingsImplCopyWithImpl(
    _$AlertSettingsImpl _value,
    $Res Function(_$AlertSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workstationId = null,
    Object? visual = null,
    Object? eventMappings = null,
    Object? quietHours = freezed,
    Object? isGlobalDefault = null,
  }) {
    return _then(
      _$AlertSettingsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        workstationId: null == workstationId
            ? _value.workstationId
            : workstationId // ignore: cast_nullable_to_non_nullable
                  as String,
        visual: null == visual
            ? _value.visual
            : visual // ignore: cast_nullable_to_non_nullable
                  as VisualSettings,
        eventMappings: null == eventMappings
            ? _value._eventMappings
            : eventMappings // ignore: cast_nullable_to_non_nullable
                  as List<EventMapping>,
        quietHours: freezed == quietHours
            ? _value.quietHours
            : quietHours // ignore: cast_nullable_to_non_nullable
                  as QuietHours?,
        isGlobalDefault: null == isGlobalDefault
            ? _value.isGlobalDefault
            : isGlobalDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertSettingsImpl implements _AlertSettings {
  const _$AlertSettingsImpl({
    required this.id,
    required this.workstationId,
    required this.visual,
    required final List<EventMapping> eventMappings,
    required this.quietHours,
    this.isGlobalDefault = false,
  }) : _eventMappings = eventMappings;

  factory _$AlertSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertSettingsImplFromJson(json);

  @override
  final String id;
  @override
  final String workstationId;
  @override
  final VisualSettings visual;
  final List<EventMapping> _eventMappings;
  @override
  List<EventMapping> get eventMappings {
    if (_eventMappings is EqualUnmodifiableListView) return _eventMappings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_eventMappings);
  }

  @override
  final QuietHours? quietHours;
  @override
  @JsonKey()
  final bool isGlobalDefault;

  @override
  String toString() {
    return 'AlertSettings(id: $id, workstationId: $workstationId, visual: $visual, eventMappings: $eventMappings, quietHours: $quietHours, isGlobalDefault: $isGlobalDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workstationId, workstationId) ||
                other.workstationId == workstationId) &&
            (identical(other.visual, visual) || other.visual == visual) &&
            const DeepCollectionEquality().equals(
              other._eventMappings,
              _eventMappings,
            ) &&
            (identical(other.quietHours, quietHours) ||
                other.quietHours == quietHours) &&
            (identical(other.isGlobalDefault, isGlobalDefault) ||
                other.isGlobalDefault == isGlobalDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workstationId,
    visual,
    const DeepCollectionEquality().hash(_eventMappings),
    quietHours,
    isGlobalDefault,
  );

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertSettingsImplCopyWith<_$AlertSettingsImpl> get copyWith =>
      __$$AlertSettingsImplCopyWithImpl<_$AlertSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertSettingsImplToJson(this);
  }
}

abstract class _AlertSettings implements AlertSettings {
  const factory _AlertSettings({
    required final String id,
    required final String workstationId,
    required final VisualSettings visual,
    required final List<EventMapping> eventMappings,
    required final QuietHours? quietHours,
    final bool isGlobalDefault,
  }) = _$AlertSettingsImpl;

  factory _AlertSettings.fromJson(Map<String, dynamic> json) =
      _$AlertSettingsImpl.fromJson;

  @override
  String get id;
  @override
  String get workstationId;
  @override
  VisualSettings get visual;
  @override
  List<EventMapping> get eventMappings;
  @override
  QuietHours? get quietHours;
  @override
  bool get isGlobalDefault;

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertSettingsImplCopyWith<_$AlertSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisualSettings _$VisualSettingsFromJson(Map<String, dynamic> json) {
  return _VisualSettings.fromJson(json);
}

/// @nodoc
mixin _$VisualSettings {
  bool get popupWindow => throw _privateConstructorUsedError;
  bool get flashScreen => throw _privateConstructorUsedError;
  bool get forceFocus => throw _privateConstructorUsedError;

  /// Serializes this VisualSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisualSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisualSettingsCopyWith<VisualSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisualSettingsCopyWith<$Res> {
  factory $VisualSettingsCopyWith(
    VisualSettings value,
    $Res Function(VisualSettings) then,
  ) = _$VisualSettingsCopyWithImpl<$Res, VisualSettings>;
  @useResult
  $Res call({bool popupWindow, bool flashScreen, bool forceFocus});
}

/// @nodoc
class _$VisualSettingsCopyWithImpl<$Res, $Val extends VisualSettings>
    implements $VisualSettingsCopyWith<$Res> {
  _$VisualSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisualSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? popupWindow = null,
    Object? flashScreen = null,
    Object? forceFocus = null,
  }) {
    return _then(
      _value.copyWith(
            popupWindow: null == popupWindow
                ? _value.popupWindow
                : popupWindow // ignore: cast_nullable_to_non_nullable
                      as bool,
            flashScreen: null == flashScreen
                ? _value.flashScreen
                : flashScreen // ignore: cast_nullable_to_non_nullable
                      as bool,
            forceFocus: null == forceFocus
                ? _value.forceFocus
                : forceFocus // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisualSettingsImplCopyWith<$Res>
    implements $VisualSettingsCopyWith<$Res> {
  factory _$$VisualSettingsImplCopyWith(
    _$VisualSettingsImpl value,
    $Res Function(_$VisualSettingsImpl) then,
  ) = __$$VisualSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool popupWindow, bool flashScreen, bool forceFocus});
}

/// @nodoc
class __$$VisualSettingsImplCopyWithImpl<$Res>
    extends _$VisualSettingsCopyWithImpl<$Res, _$VisualSettingsImpl>
    implements _$$VisualSettingsImplCopyWith<$Res> {
  __$$VisualSettingsImplCopyWithImpl(
    _$VisualSettingsImpl _value,
    $Res Function(_$VisualSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisualSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? popupWindow = null,
    Object? flashScreen = null,
    Object? forceFocus = null,
  }) {
    return _then(
      _$VisualSettingsImpl(
        popupWindow: null == popupWindow
            ? _value.popupWindow
            : popupWindow // ignore: cast_nullable_to_non_nullable
                  as bool,
        flashScreen: null == flashScreen
            ? _value.flashScreen
            : flashScreen // ignore: cast_nullable_to_non_nullable
                  as bool,
        forceFocus: null == forceFocus
            ? _value.forceFocus
            : forceFocus // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisualSettingsImpl implements _VisualSettings {
  const _$VisualSettingsImpl({
    this.popupWindow = true,
    this.flashScreen = true,
    this.forceFocus = false,
  });

  factory _$VisualSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisualSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool popupWindow;
  @override
  @JsonKey()
  final bool flashScreen;
  @override
  @JsonKey()
  final bool forceFocus;

  @override
  String toString() {
    return 'VisualSettings(popupWindow: $popupWindow, flashScreen: $flashScreen, forceFocus: $forceFocus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisualSettingsImpl &&
            (identical(other.popupWindow, popupWindow) ||
                other.popupWindow == popupWindow) &&
            (identical(other.flashScreen, flashScreen) ||
                other.flashScreen == flashScreen) &&
            (identical(other.forceFocus, forceFocus) ||
                other.forceFocus == forceFocus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, popupWindow, flashScreen, forceFocus);

  /// Create a copy of VisualSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisualSettingsImplCopyWith<_$VisualSettingsImpl> get copyWith =>
      __$$VisualSettingsImplCopyWithImpl<_$VisualSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VisualSettingsImplToJson(this);
  }
}

abstract class _VisualSettings implements VisualSettings {
  const factory _VisualSettings({
    final bool popupWindow,
    final bool flashScreen,
    final bool forceFocus,
  }) = _$VisualSettingsImpl;

  factory _VisualSettings.fromJson(Map<String, dynamic> json) =
      _$VisualSettingsImpl.fromJson;

  @override
  bool get popupWindow;
  @override
  bool get flashScreen;
  @override
  bool get forceFocus;

  /// Create a copy of VisualSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisualSettingsImplCopyWith<_$VisualSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventMapping _$EventMappingFromJson(Map<String, dynamic> json) {
  return _EventMapping.fromJson(json);
}

/// @nodoc
mixin _$EventMapping {
  String get id => throw _privateConstructorUsedError;
  String get eventName => throw _privateConstructorUsedError;
  String get eventDescription => throw _privateConstructorUsedError;
  AlertEventPriority get priority => throw _privateConstructorUsedError;
  String get soundId => throw _privateConstructorUsedError;
  int get volume => throw _privateConstructorUsedError;

  /// Serializes this EventMapping to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventMappingCopyWith<EventMapping> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventMappingCopyWith<$Res> {
  factory $EventMappingCopyWith(
    EventMapping value,
    $Res Function(EventMapping) then,
  ) = _$EventMappingCopyWithImpl<$Res, EventMapping>;
  @useResult
  $Res call({
    String id,
    String eventName,
    String eventDescription,
    AlertEventPriority priority,
    String soundId,
    int volume,
  });
}

/// @nodoc
class _$EventMappingCopyWithImpl<$Res, $Val extends EventMapping>
    implements $EventMappingCopyWith<$Res> {
  _$EventMappingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventName = null,
    Object? eventDescription = null,
    Object? priority = null,
    Object? soundId = null,
    Object? volume = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            eventName: null == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDescription: null == eventDescription
                ? _value.eventDescription
                : eventDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as AlertEventPriority,
            soundId: null == soundId
                ? _value.soundId
                : soundId // ignore: cast_nullable_to_non_nullable
                      as String,
            volume: null == volume
                ? _value.volume
                : volume // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventMappingImplCopyWith<$Res>
    implements $EventMappingCopyWith<$Res> {
  factory _$$EventMappingImplCopyWith(
    _$EventMappingImpl value,
    $Res Function(_$EventMappingImpl) then,
  ) = __$$EventMappingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String eventName,
    String eventDescription,
    AlertEventPriority priority,
    String soundId,
    int volume,
  });
}

/// @nodoc
class __$$EventMappingImplCopyWithImpl<$Res>
    extends _$EventMappingCopyWithImpl<$Res, _$EventMappingImpl>
    implements _$$EventMappingImplCopyWith<$Res> {
  __$$EventMappingImplCopyWithImpl(
    _$EventMappingImpl _value,
    $Res Function(_$EventMappingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventName = null,
    Object? eventDescription = null,
    Object? priority = null,
    Object? soundId = null,
    Object? volume = null,
  }) {
    return _then(
      _$EventMappingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDescription: null == eventDescription
            ? _value.eventDescription
            : eventDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as AlertEventPriority,
        soundId: null == soundId
            ? _value.soundId
            : soundId // ignore: cast_nullable_to_non_nullable
                  as String,
        volume: null == volume
            ? _value.volume
            : volume // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventMappingImpl implements _EventMapping {
  const _$EventMappingImpl({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.priority,
    required this.soundId,
    required this.volume,
  });

  factory _$EventMappingImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventMappingImplFromJson(json);

  @override
  final String id;
  @override
  final String eventName;
  @override
  final String eventDescription;
  @override
  final AlertEventPriority priority;
  @override
  final String soundId;
  @override
  final int volume;

  @override
  String toString() {
    return 'EventMapping(id: $id, eventName: $eventName, eventDescription: $eventDescription, priority: $priority, soundId: $soundId, volume: $volume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventMappingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDescription, eventDescription) ||
                other.eventDescription == eventDescription) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.soundId, soundId) || other.soundId == soundId) &&
            (identical(other.volume, volume) || other.volume == volume));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventName,
    eventDescription,
    priority,
    soundId,
    volume,
  );

  /// Create a copy of EventMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventMappingImplCopyWith<_$EventMappingImpl> get copyWith =>
      __$$EventMappingImplCopyWithImpl<_$EventMappingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventMappingImplToJson(this);
  }
}

abstract class _EventMapping implements EventMapping {
  const factory _EventMapping({
    required final String id,
    required final String eventName,
    required final String eventDescription,
    required final AlertEventPriority priority,
    required final String soundId,
    required final int volume,
  }) = _$EventMappingImpl;

  factory _EventMapping.fromJson(Map<String, dynamic> json) =
      _$EventMappingImpl.fromJson;

  @override
  String get id;
  @override
  String get eventName;
  @override
  String get eventDescription;
  @override
  AlertEventPriority get priority;
  @override
  String get soundId;
  @override
  int get volume;

  /// Create a copy of EventMapping
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventMappingImplCopyWith<_$EventMappingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuietHours _$QuietHoursFromJson(Map<String, dynamic> json) {
  return _QuietHours.fromJson(json);
}

/// @nodoc
mixin _$QuietHours {
  String get startTime => throw _privateConstructorUsedError; // HH:mm format
  String get endTime => throw _privateConstructorUsedError; // HH:mm format
  bool get enabled => throw _privateConstructorUsedError;

  /// Serializes this QuietHours to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuietHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuietHoursCopyWith<QuietHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuietHoursCopyWith<$Res> {
  factory $QuietHoursCopyWith(
    QuietHours value,
    $Res Function(QuietHours) then,
  ) = _$QuietHoursCopyWithImpl<$Res, QuietHours>;
  @useResult
  $Res call({String startTime, String endTime, bool enabled});
}

/// @nodoc
class _$QuietHoursCopyWithImpl<$Res, $Val extends QuietHours>
    implements $QuietHoursCopyWith<$Res> {
  _$QuietHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuietHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? enabled = null,
  }) {
    return _then(
      _value.copyWith(
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuietHoursImplCopyWith<$Res>
    implements $QuietHoursCopyWith<$Res> {
  factory _$$QuietHoursImplCopyWith(
    _$QuietHoursImpl value,
    $Res Function(_$QuietHoursImpl) then,
  ) = __$$QuietHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String startTime, String endTime, bool enabled});
}

/// @nodoc
class __$$QuietHoursImplCopyWithImpl<$Res>
    extends _$QuietHoursCopyWithImpl<$Res, _$QuietHoursImpl>
    implements _$$QuietHoursImplCopyWith<$Res> {
  __$$QuietHoursImplCopyWithImpl(
    _$QuietHoursImpl _value,
    $Res Function(_$QuietHoursImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuietHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? enabled = null,
  }) {
    return _then(
      _$QuietHoursImpl(
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuietHoursImpl implements _QuietHours {
  const _$QuietHoursImpl({
    required this.startTime,
    required this.endTime,
    this.enabled = false,
  });

  factory _$QuietHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuietHoursImplFromJson(json);

  @override
  final String startTime;
  // HH:mm format
  @override
  final String endTime;
  // HH:mm format
  @override
  @JsonKey()
  final bool enabled;

  @override
  String toString() {
    return 'QuietHours(startTime: $startTime, endTime: $endTime, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuietHoursImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime, enabled);

  /// Create a copy of QuietHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuietHoursImplCopyWith<_$QuietHoursImpl> get copyWith =>
      __$$QuietHoursImplCopyWithImpl<_$QuietHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuietHoursImplToJson(this);
  }
}

abstract class _QuietHours implements QuietHours {
  const factory _QuietHours({
    required final String startTime,
    required final String endTime,
    final bool enabled,
  }) = _$QuietHoursImpl;

  factory _QuietHours.fromJson(Map<String, dynamic> json) =
      _$QuietHoursImpl.fromJson;

  @override
  String get startTime; // HH:mm format
  @override
  String get endTime; // HH:mm format
  @override
  bool get enabled;

  /// Create a copy of QuietHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuietHoursImplCopyWith<_$QuietHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SoundOption _$SoundOptionFromJson(Map<String, dynamic> json) {
  return _SoundOption.fromJson(json);
}

/// @nodoc
mixin _$SoundOption {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;

  /// Serializes this SoundOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SoundOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SoundOptionCopyWith<SoundOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoundOptionCopyWith<$Res> {
  factory $SoundOptionCopyWith(
    SoundOption value,
    $Res Function(SoundOption) then,
  ) = _$SoundOptionCopyWithImpl<$Res, SoundOption>;
  @useResult
  $Res call({String id, String name, String icon});
}

/// @nodoc
class _$SoundOptionCopyWithImpl<$Res, $Val extends SoundOption>
    implements $SoundOptionCopyWith<$Res> {
  _$SoundOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SoundOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? icon = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SoundOptionImplCopyWith<$Res>
    implements $SoundOptionCopyWith<$Res> {
  factory _$$SoundOptionImplCopyWith(
    _$SoundOptionImpl value,
    $Res Function(_$SoundOptionImpl) then,
  ) = __$$SoundOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String icon});
}

/// @nodoc
class __$$SoundOptionImplCopyWithImpl<$Res>
    extends _$SoundOptionCopyWithImpl<$Res, _$SoundOptionImpl>
    implements _$$SoundOptionImplCopyWith<$Res> {
  __$$SoundOptionImplCopyWithImpl(
    _$SoundOptionImpl _value,
    $Res Function(_$SoundOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SoundOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? icon = null}) {
    return _then(
      _$SoundOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SoundOptionImpl implements _SoundOption {
  const _$SoundOptionImpl({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory _$SoundOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SoundOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;

  @override
  String toString() {
    return 'SoundOption(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoundOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon);

  /// Create a copy of SoundOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SoundOptionImplCopyWith<_$SoundOptionImpl> get copyWith =>
      __$$SoundOptionImplCopyWithImpl<_$SoundOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SoundOptionImplToJson(this);
  }
}

abstract class _SoundOption implements SoundOption {
  const factory _SoundOption({
    required final String id,
    required final String name,
    required final String icon,
  }) = _$SoundOptionImpl;

  factory _SoundOption.fromJson(Map<String, dynamic> json) =
      _$SoundOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;

  /// Create a copy of SoundOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SoundOptionImplCopyWith<_$SoundOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
