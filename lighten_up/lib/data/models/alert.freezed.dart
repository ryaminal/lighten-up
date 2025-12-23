// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Alert _$AlertFromJson(Map<String, dynamic> json) {
  return _Alert.fromJson(json);
}

/// @nodoc
mixin _$Alert {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  AlertType get type => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;
  AlertStatus get status => throw _privateConstructorUsedError;
  String? get patientId => throw _privateConstructorUsedError;
  String? get patientName => throw _privateConstructorUsedError;
  String? get roomNumber => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get assignedToId => throw _privateConstructorUsedError;
  String? get assignedToName => throw _privateConstructorUsedError;
  String? get acknowledgedById => throw _privateConstructorUsedError;
  String? get acknowledgedByName => throw _privateConstructorUsedError;
  DateTime? get acknowledgedAt => throw _privateConstructorUsedError;
  String? get resolvedById => throw _privateConstructorUsedError;
  String? get resolvedByName => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String> get notifiedUserIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Alert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertCopyWith<Alert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) then) =
      _$AlertCopyWithImpl<$Res, Alert>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    AlertType type,
    AlertSeverity severity,
    AlertStatus status,
    String? patientId,
    String? patientName,
    String? roomNumber,
    String? location,
    String? assignedToId,
    String? assignedToName,
    String? acknowledgedById,
    String? acknowledgedByName,
    DateTime? acknowledgedAt,
    String? resolvedById,
    String? resolvedByName,
    DateTime? resolvedAt,
    String? notes,
    Map<String, dynamic>? metadata,
    List<String> notifiedUserIds,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AlertCopyWithImpl<$Res, $Val extends Alert>
    implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? severity = null,
    Object? status = null,
    Object? patientId = freezed,
    Object? patientName = freezed,
    Object? roomNumber = freezed,
    Object? location = freezed,
    Object? assignedToId = freezed,
    Object? assignedToName = freezed,
    Object? acknowledgedById = freezed,
    Object? acknowledgedByName = freezed,
    Object? acknowledgedAt = freezed,
    Object? resolvedById = freezed,
    Object? resolvedByName = freezed,
    Object? resolvedAt = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? notifiedUserIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AlertType,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as AlertSeverity,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AlertStatus,
            patientId: freezed == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientName: freezed == patientName
                ? _value.patientName
                : patientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            roomNumber: freezed == roomNumber
                ? _value.roomNumber
                : roomNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToId: freezed == assignedToId
                ? _value.assignedToId
                : assignedToId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToName: freezed == assignedToName
                ? _value.assignedToName
                : assignedToName // ignore: cast_nullable_to_non_nullable
                      as String?,
            acknowledgedById: freezed == acknowledgedById
                ? _value.acknowledgedById
                : acknowledgedById // ignore: cast_nullable_to_non_nullable
                      as String?,
            acknowledgedByName: freezed == acknowledgedByName
                ? _value.acknowledgedByName
                : acknowledgedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            acknowledgedAt: freezed == acknowledgedAt
                ? _value.acknowledgedAt
                : acknowledgedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedById: freezed == resolvedById
                ? _value.resolvedById
                : resolvedById // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedByName: freezed == resolvedByName
                ? _value.resolvedByName
                : resolvedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            notifiedUserIds: null == notifiedUserIds
                ? _value.notifiedUserIds
                : notifiedUserIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlertImplCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$$AlertImplCopyWith(
    _$AlertImpl value,
    $Res Function(_$AlertImpl) then,
  ) = __$$AlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    AlertType type,
    AlertSeverity severity,
    AlertStatus status,
    String? patientId,
    String? patientName,
    String? roomNumber,
    String? location,
    String? assignedToId,
    String? assignedToName,
    String? acknowledgedById,
    String? acknowledgedByName,
    DateTime? acknowledgedAt,
    String? resolvedById,
    String? resolvedByName,
    DateTime? resolvedAt,
    String? notes,
    Map<String, dynamic>? metadata,
    List<String> notifiedUserIds,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AlertImplCopyWithImpl<$Res>
    extends _$AlertCopyWithImpl<$Res, _$AlertImpl>
    implements _$$AlertImplCopyWith<$Res> {
  __$$AlertImplCopyWithImpl(
    _$AlertImpl _value,
    $Res Function(_$AlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? severity = null,
    Object? status = null,
    Object? patientId = freezed,
    Object? patientName = freezed,
    Object? roomNumber = freezed,
    Object? location = freezed,
    Object? assignedToId = freezed,
    Object? assignedToName = freezed,
    Object? acknowledgedById = freezed,
    Object? acknowledgedByName = freezed,
    Object? acknowledgedAt = freezed,
    Object? resolvedById = freezed,
    Object? resolvedByName = freezed,
    Object? resolvedAt = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? notifiedUserIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AlertImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AlertType,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as AlertSeverity,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AlertStatus,
        patientId: freezed == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientName: freezed == patientName
            ? _value.patientName
            : patientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        roomNumber: freezed == roomNumber
            ? _value.roomNumber
            : roomNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToId: freezed == assignedToId
            ? _value.assignedToId
            : assignedToId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToName: freezed == assignedToName
            ? _value.assignedToName
            : assignedToName // ignore: cast_nullable_to_non_nullable
                  as String?,
        acknowledgedById: freezed == acknowledgedById
            ? _value.acknowledgedById
            : acknowledgedById // ignore: cast_nullable_to_non_nullable
                  as String?,
        acknowledgedByName: freezed == acknowledgedByName
            ? _value.acknowledgedByName
            : acknowledgedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        acknowledgedAt: freezed == acknowledgedAt
            ? _value.acknowledgedAt
            : acknowledgedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedById: freezed == resolvedById
            ? _value.resolvedById
            : resolvedById // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedByName: freezed == resolvedByName
            ? _value.resolvedByName
            : resolvedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        notifiedUserIds: null == notifiedUserIds
            ? _value._notifiedUserIds
            : notifiedUserIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertImpl extends _Alert {
  const _$AlertImpl({
    required this.id,
    required this.title,
    required this.description,
    this.type = AlertType.system,
    this.severity = AlertSeverity.medium,
    this.status = AlertStatus.active,
    this.patientId,
    this.patientName,
    this.roomNumber,
    this.location,
    this.assignedToId,
    this.assignedToName,
    this.acknowledgedById,
    this.acknowledgedByName,
    this.acknowledgedAt,
    this.resolvedById,
    this.resolvedByName,
    this.resolvedAt,
    this.notes,
    final Map<String, dynamic>? metadata,
    final List<String> notifiedUserIds = const [],
    required this.createdAt,
    this.updatedAt,
  }) : _metadata = metadata,
       _notifiedUserIds = notifiedUserIds,
       super._();

  factory _$AlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final AlertType type;
  @override
  @JsonKey()
  final AlertSeverity severity;
  @override
  @JsonKey()
  final AlertStatus status;
  @override
  final String? patientId;
  @override
  final String? patientName;
  @override
  final String? roomNumber;
  @override
  final String? location;
  @override
  final String? assignedToId;
  @override
  final String? assignedToName;
  @override
  final String? acknowledgedById;
  @override
  final String? acknowledgedByName;
  @override
  final DateTime? acknowledgedAt;
  @override
  final String? resolvedById;
  @override
  final String? resolvedByName;
  @override
  final DateTime? resolvedAt;
  @override
  final String? notes;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String> _notifiedUserIds;
  @override
  @JsonKey()
  List<String> get notifiedUserIds {
    if (_notifiedUserIds is EqualUnmodifiableListView) return _notifiedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifiedUserIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Alert(id: $id, title: $title, description: $description, type: $type, severity: $severity, status: $status, patientId: $patientId, patientName: $patientName, roomNumber: $roomNumber, location: $location, assignedToId: $assignedToId, assignedToName: $assignedToName, acknowledgedById: $acknowledgedById, acknowledgedByName: $acknowledgedByName, acknowledgedAt: $acknowledgedAt, resolvedById: $resolvedById, resolvedByName: $resolvedByName, resolvedAt: $resolvedAt, notes: $notes, metadata: $metadata, notifiedUserIds: $notifiedUserIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.assignedToId, assignedToId) ||
                other.assignedToId == assignedToId) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.acknowledgedById, acknowledgedById) ||
                other.acknowledgedById == acknowledgedById) &&
            (identical(other.acknowledgedByName, acknowledgedByName) ||
                other.acknowledgedByName == acknowledgedByName) &&
            (identical(other.acknowledgedAt, acknowledgedAt) ||
                other.acknowledgedAt == acknowledgedAt) &&
            (identical(other.resolvedById, resolvedById) ||
                other.resolvedById == resolvedById) &&
            (identical(other.resolvedByName, resolvedByName) ||
                other.resolvedByName == resolvedByName) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(
              other._notifiedUserIds,
              _notifiedUserIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    type,
    severity,
    status,
    patientId,
    patientName,
    roomNumber,
    location,
    assignedToId,
    assignedToName,
    acknowledgedById,
    acknowledgedByName,
    acknowledgedAt,
    resolvedById,
    resolvedByName,
    resolvedAt,
    notes,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_notifiedUserIds),
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      __$$AlertImplCopyWithImpl<_$AlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertImplToJson(this);
  }
}

abstract class _Alert extends Alert {
  const factory _Alert({
    required final String id,
    required final String title,
    required final String description,
    final AlertType type,
    final AlertSeverity severity,
    final AlertStatus status,
    final String? patientId,
    final String? patientName,
    final String? roomNumber,
    final String? location,
    final String? assignedToId,
    final String? assignedToName,
    final String? acknowledgedById,
    final String? acknowledgedByName,
    final DateTime? acknowledgedAt,
    final String? resolvedById,
    final String? resolvedByName,
    final DateTime? resolvedAt,
    final String? notes,
    final Map<String, dynamic>? metadata,
    final List<String> notifiedUserIds,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$AlertImpl;
  const _Alert._() : super._();

  factory _Alert.fromJson(Map<String, dynamic> json) = _$AlertImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  AlertType get type;
  @override
  AlertSeverity get severity;
  @override
  AlertStatus get status;
  @override
  String? get patientId;
  @override
  String? get patientName;
  @override
  String? get roomNumber;
  @override
  String? get location;
  @override
  String? get assignedToId;
  @override
  String? get assignedToName;
  @override
  String? get acknowledgedById;
  @override
  String? get acknowledgedByName;
  @override
  DateTime? get acknowledgedAt;
  @override
  String? get resolvedById;
  @override
  String? get resolvedByName;
  @override
  DateTime? get resolvedAt;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String> get notifiedUserIds;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlertSettings _$AlertSettingsFromJson(Map<String, dynamic> json) {
  return _AlertSettings.fromJson(json);
}

/// @nodoc
mixin _$AlertSettings {
  String get userId => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get vibrationEnabled => throw _privateConstructorUsedError;
  bool get criticalAlertsEnabled => throw _privateConstructorUsedError;
  bool get emergencyAlertsEnabled => throw _privateConstructorUsedError;
  bool get medicalAlertsEnabled => throw _privateConstructorUsedError;
  bool get medicationAlertsEnabled => throw _privateConstructorUsedError;
  bool get vitalsAlertsEnabled => throw _privateConstructorUsedError;
  int get autoAcknowledgeMinutes => throw _privateConstructorUsedError;
  String? get customSoundUrl => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
    String userId,
    bool enabled,
    bool soundEnabled,
    bool vibrationEnabled,
    bool criticalAlertsEnabled,
    bool emergencyAlertsEnabled,
    bool medicalAlertsEnabled,
    bool medicationAlertsEnabled,
    bool vitalsAlertsEnabled,
    int autoAcknowledgeMinutes,
    String? customSoundUrl,
    DateTime? updatedAt,
  });
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
    Object? userId = null,
    Object? enabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? criticalAlertsEnabled = null,
    Object? emergencyAlertsEnabled = null,
    Object? medicalAlertsEnabled = null,
    Object? medicationAlertsEnabled = null,
    Object? vitalsAlertsEnabled = null,
    Object? autoAcknowledgeMinutes = null,
    Object? customSoundUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            soundEnabled: null == soundEnabled
                ? _value.soundEnabled
                : soundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            vibrationEnabled: null == vibrationEnabled
                ? _value.vibrationEnabled
                : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            criticalAlertsEnabled: null == criticalAlertsEnabled
                ? _value.criticalAlertsEnabled
                : criticalAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            emergencyAlertsEnabled: null == emergencyAlertsEnabled
                ? _value.emergencyAlertsEnabled
                : emergencyAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            medicalAlertsEnabled: null == medicalAlertsEnabled
                ? _value.medicalAlertsEnabled
                : medicalAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            medicationAlertsEnabled: null == medicationAlertsEnabled
                ? _value.medicationAlertsEnabled
                : medicationAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            vitalsAlertsEnabled: null == vitalsAlertsEnabled
                ? _value.vitalsAlertsEnabled
                : vitalsAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoAcknowledgeMinutes: null == autoAcknowledgeMinutes
                ? _value.autoAcknowledgeMinutes
                : autoAcknowledgeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            customSoundUrl: freezed == customSoundUrl
                ? _value.customSoundUrl
                : customSoundUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
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
    String userId,
    bool enabled,
    bool soundEnabled,
    bool vibrationEnabled,
    bool criticalAlertsEnabled,
    bool emergencyAlertsEnabled,
    bool medicalAlertsEnabled,
    bool medicationAlertsEnabled,
    bool vitalsAlertsEnabled,
    int autoAcknowledgeMinutes,
    String? customSoundUrl,
    DateTime? updatedAt,
  });
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
    Object? userId = null,
    Object? enabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? criticalAlertsEnabled = null,
    Object? emergencyAlertsEnabled = null,
    Object? medicalAlertsEnabled = null,
    Object? medicationAlertsEnabled = null,
    Object? vitalsAlertsEnabled = null,
    Object? autoAcknowledgeMinutes = null,
    Object? customSoundUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AlertSettingsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        soundEnabled: null == soundEnabled
            ? _value.soundEnabled
            : soundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        vibrationEnabled: null == vibrationEnabled
            ? _value.vibrationEnabled
            : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        criticalAlertsEnabled: null == criticalAlertsEnabled
            ? _value.criticalAlertsEnabled
            : criticalAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        emergencyAlertsEnabled: null == emergencyAlertsEnabled
            ? _value.emergencyAlertsEnabled
            : emergencyAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        medicalAlertsEnabled: null == medicalAlertsEnabled
            ? _value.medicalAlertsEnabled
            : medicalAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        medicationAlertsEnabled: null == medicationAlertsEnabled
            ? _value.medicationAlertsEnabled
            : medicationAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        vitalsAlertsEnabled: null == vitalsAlertsEnabled
            ? _value.vitalsAlertsEnabled
            : vitalsAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoAcknowledgeMinutes: null == autoAcknowledgeMinutes
            ? _value.autoAcknowledgeMinutes
            : autoAcknowledgeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        customSoundUrl: freezed == customSoundUrl
            ? _value.customSoundUrl
            : customSoundUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertSettingsImpl implements _AlertSettings {
  const _$AlertSettingsImpl({
    required this.userId,
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.criticalAlertsEnabled = true,
    this.emergencyAlertsEnabled = true,
    this.medicalAlertsEnabled = true,
    this.medicationAlertsEnabled = true,
    this.vitalsAlertsEnabled = true,
    this.autoAcknowledgeMinutes = 5,
    this.customSoundUrl,
    this.updatedAt,
  });

  factory _$AlertSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertSettingsImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool vibrationEnabled;
  @override
  @JsonKey()
  final bool criticalAlertsEnabled;
  @override
  @JsonKey()
  final bool emergencyAlertsEnabled;
  @override
  @JsonKey()
  final bool medicalAlertsEnabled;
  @override
  @JsonKey()
  final bool medicationAlertsEnabled;
  @override
  @JsonKey()
  final bool vitalsAlertsEnabled;
  @override
  @JsonKey()
  final int autoAcknowledgeMinutes;
  @override
  final String? customSoundUrl;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AlertSettings(userId: $userId, enabled: $enabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, criticalAlertsEnabled: $criticalAlertsEnabled, emergencyAlertsEnabled: $emergencyAlertsEnabled, medicalAlertsEnabled: $medicalAlertsEnabled, medicationAlertsEnabled: $medicationAlertsEnabled, vitalsAlertsEnabled: $vitalsAlertsEnabled, autoAcknowledgeMinutes: $autoAcknowledgeMinutes, customSoundUrl: $customSoundUrl, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertSettingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.criticalAlertsEnabled, criticalAlertsEnabled) ||
                other.criticalAlertsEnabled == criticalAlertsEnabled) &&
            (identical(other.emergencyAlertsEnabled, emergencyAlertsEnabled) ||
                other.emergencyAlertsEnabled == emergencyAlertsEnabled) &&
            (identical(other.medicalAlertsEnabled, medicalAlertsEnabled) ||
                other.medicalAlertsEnabled == medicalAlertsEnabled) &&
            (identical(
                  other.medicationAlertsEnabled,
                  medicationAlertsEnabled,
                ) ||
                other.medicationAlertsEnabled == medicationAlertsEnabled) &&
            (identical(other.vitalsAlertsEnabled, vitalsAlertsEnabled) ||
                other.vitalsAlertsEnabled == vitalsAlertsEnabled) &&
            (identical(other.autoAcknowledgeMinutes, autoAcknowledgeMinutes) ||
                other.autoAcknowledgeMinutes == autoAcknowledgeMinutes) &&
            (identical(other.customSoundUrl, customSoundUrl) ||
                other.customSoundUrl == customSoundUrl) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    enabled,
    soundEnabled,
    vibrationEnabled,
    criticalAlertsEnabled,
    emergencyAlertsEnabled,
    medicalAlertsEnabled,
    medicationAlertsEnabled,
    vitalsAlertsEnabled,
    autoAcknowledgeMinutes,
    customSoundUrl,
    updatedAt,
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
    required final String userId,
    final bool enabled,
    final bool soundEnabled,
    final bool vibrationEnabled,
    final bool criticalAlertsEnabled,
    final bool emergencyAlertsEnabled,
    final bool medicalAlertsEnabled,
    final bool medicationAlertsEnabled,
    final bool vitalsAlertsEnabled,
    final int autoAcknowledgeMinutes,
    final String? customSoundUrl,
    final DateTime? updatedAt,
  }) = _$AlertSettingsImpl;

  factory _AlertSettings.fromJson(Map<String, dynamic> json) =
      _$AlertSettingsImpl.fromJson;

  @override
  String get userId;
  @override
  bool get enabled;
  @override
  bool get soundEnabled;
  @override
  bool get vibrationEnabled;
  @override
  bool get criticalAlertsEnabled;
  @override
  bool get emergencyAlertsEnabled;
  @override
  bool get medicalAlertsEnabled;
  @override
  bool get medicationAlertsEnabled;
  @override
  bool get vitalsAlertsEnabled;
  @override
  int get autoAcknowledgeMinutes;
  @override
  String? get customSoundUrl;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AlertSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertSettingsImplCopyWith<_$AlertSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AcknowledgeAlertRequest _$AcknowledgeAlertRequestFromJson(
  Map<String, dynamic> json,
) {
  return _AcknowledgeAlertRequest.fromJson(json);
}

/// @nodoc
mixin _$AcknowledgeAlertRequest {
  String get alertId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this AcknowledgeAlertRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcknowledgeAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcknowledgeAlertRequestCopyWith<AcknowledgeAlertRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcknowledgeAlertRequestCopyWith<$Res> {
  factory $AcknowledgeAlertRequestCopyWith(
    AcknowledgeAlertRequest value,
    $Res Function(AcknowledgeAlertRequest) then,
  ) = _$AcknowledgeAlertRequestCopyWithImpl<$Res, AcknowledgeAlertRequest>;
  @useResult
  $Res call({String alertId, String userId, String? notes});
}

/// @nodoc
class _$AcknowledgeAlertRequestCopyWithImpl<
  $Res,
  $Val extends AcknowledgeAlertRequest
>
    implements $AcknowledgeAlertRequestCopyWith<$Res> {
  _$AcknowledgeAlertRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcknowledgeAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? userId = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            alertId: null == alertId
                ? _value.alertId
                : alertId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AcknowledgeAlertRequestImplCopyWith<$Res>
    implements $AcknowledgeAlertRequestCopyWith<$Res> {
  factory _$$AcknowledgeAlertRequestImplCopyWith(
    _$AcknowledgeAlertRequestImpl value,
    $Res Function(_$AcknowledgeAlertRequestImpl) then,
  ) = __$$AcknowledgeAlertRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String alertId, String userId, String? notes});
}

/// @nodoc
class __$$AcknowledgeAlertRequestImplCopyWithImpl<$Res>
    extends
        _$AcknowledgeAlertRequestCopyWithImpl<
          $Res,
          _$AcknowledgeAlertRequestImpl
        >
    implements _$$AcknowledgeAlertRequestImplCopyWith<$Res> {
  __$$AcknowledgeAlertRequestImplCopyWithImpl(
    _$AcknowledgeAlertRequestImpl _value,
    $Res Function(_$AcknowledgeAlertRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AcknowledgeAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? userId = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$AcknowledgeAlertRequestImpl(
        alertId: null == alertId
            ? _value.alertId
            : alertId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AcknowledgeAlertRequestImpl implements _AcknowledgeAlertRequest {
  const _$AcknowledgeAlertRequestImpl({
    required this.alertId,
    required this.userId,
    this.notes,
  });

  factory _$AcknowledgeAlertRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcknowledgeAlertRequestImplFromJson(json);

  @override
  final String alertId;
  @override
  final String userId;
  @override
  final String? notes;

  @override
  String toString() {
    return 'AcknowledgeAlertRequest(alertId: $alertId, userId: $userId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcknowledgeAlertRequestImpl &&
            (identical(other.alertId, alertId) || other.alertId == alertId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alertId, userId, notes);

  /// Create a copy of AcknowledgeAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcknowledgeAlertRequestImplCopyWith<_$AcknowledgeAlertRequestImpl>
  get copyWith =>
      __$$AcknowledgeAlertRequestImplCopyWithImpl<
        _$AcknowledgeAlertRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AcknowledgeAlertRequestImplToJson(this);
  }
}

abstract class _AcknowledgeAlertRequest implements AcknowledgeAlertRequest {
  const factory _AcknowledgeAlertRequest({
    required final String alertId,
    required final String userId,
    final String? notes,
  }) = _$AcknowledgeAlertRequestImpl;

  factory _AcknowledgeAlertRequest.fromJson(Map<String, dynamic> json) =
      _$AcknowledgeAlertRequestImpl.fromJson;

  @override
  String get alertId;
  @override
  String get userId;
  @override
  String? get notes;

  /// Create a copy of AcknowledgeAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcknowledgeAlertRequestImplCopyWith<_$AcknowledgeAlertRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ResolveAlertRequest _$ResolveAlertRequestFromJson(Map<String, dynamic> json) {
  return _ResolveAlertRequest.fromJson(json);
}

/// @nodoc
mixin _$ResolveAlertRequest {
  String get alertId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;

  /// Serializes this ResolveAlertRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResolveAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResolveAlertRequestCopyWith<ResolveAlertRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResolveAlertRequestCopyWith<$Res> {
  factory $ResolveAlertRequestCopyWith(
    ResolveAlertRequest value,
    $Res Function(ResolveAlertRequest) then,
  ) = _$ResolveAlertRequestCopyWithImpl<$Res, ResolveAlertRequest>;
  @useResult
  $Res call({String alertId, String userId, String? notes, String? resolution});
}

/// @nodoc
class _$ResolveAlertRequestCopyWithImpl<$Res, $Val extends ResolveAlertRequest>
    implements $ResolveAlertRequestCopyWith<$Res> {
  _$ResolveAlertRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResolveAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? userId = null,
    Object? notes = freezed,
    Object? resolution = freezed,
  }) {
    return _then(
      _value.copyWith(
            alertId: null == alertId
                ? _value.alertId
                : alertId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolution: freezed == resolution
                ? _value.resolution
                : resolution // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResolveAlertRequestImplCopyWith<$Res>
    implements $ResolveAlertRequestCopyWith<$Res> {
  factory _$$ResolveAlertRequestImplCopyWith(
    _$ResolveAlertRequestImpl value,
    $Res Function(_$ResolveAlertRequestImpl) then,
  ) = __$$ResolveAlertRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String alertId, String userId, String? notes, String? resolution});
}

/// @nodoc
class __$$ResolveAlertRequestImplCopyWithImpl<$Res>
    extends _$ResolveAlertRequestCopyWithImpl<$Res, _$ResolveAlertRequestImpl>
    implements _$$ResolveAlertRequestImplCopyWith<$Res> {
  __$$ResolveAlertRequestImplCopyWithImpl(
    _$ResolveAlertRequestImpl _value,
    $Res Function(_$ResolveAlertRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResolveAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? userId = null,
    Object? notes = freezed,
    Object? resolution = freezed,
  }) {
    return _then(
      _$ResolveAlertRequestImpl(
        alertId: null == alertId
            ? _value.alertId
            : alertId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolution: freezed == resolution
            ? _value.resolution
            : resolution // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResolveAlertRequestImpl implements _ResolveAlertRequest {
  const _$ResolveAlertRequestImpl({
    required this.alertId,
    required this.userId,
    this.notes,
    this.resolution,
  });

  factory _$ResolveAlertRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResolveAlertRequestImplFromJson(json);

  @override
  final String alertId;
  @override
  final String userId;
  @override
  final String? notes;
  @override
  final String? resolution;

  @override
  String toString() {
    return 'ResolveAlertRequest(alertId: $alertId, userId: $userId, notes: $notes, resolution: $resolution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResolveAlertRequestImpl &&
            (identical(other.alertId, alertId) || other.alertId == alertId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, alertId, userId, notes, resolution);

  /// Create a copy of ResolveAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResolveAlertRequestImplCopyWith<_$ResolveAlertRequestImpl> get copyWith =>
      __$$ResolveAlertRequestImplCopyWithImpl<_$ResolveAlertRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResolveAlertRequestImplToJson(this);
  }
}

abstract class _ResolveAlertRequest implements ResolveAlertRequest {
  const factory _ResolveAlertRequest({
    required final String alertId,
    required final String userId,
    final String? notes,
    final String? resolution,
  }) = _$ResolveAlertRequestImpl;

  factory _ResolveAlertRequest.fromJson(Map<String, dynamic> json) =
      _$ResolveAlertRequestImpl.fromJson;

  @override
  String get alertId;
  @override
  String get userId;
  @override
  String? get notes;
  @override
  String? get resolution;

  /// Create a copy of ResolveAlertRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResolveAlertRequestImplCopyWith<_$ResolveAlertRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
