// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoomLight _$RoomLightFromJson(Map<String, dynamic> json) {
  return _RoomLight.fromJson(json);
}

/// @nodoc
mixin _$RoomLight {
  String get id => throw _privateConstructorUsedError;
  LightType get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  LightStatus get status => throw _privateConstructorUsedError;
  LightPriority get priority => throw _privateConstructorUsedError;
  String? get activatedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'activated_by_name')
  String? get activatedByName => throw _privateConstructorUsedError;
  DateTime? get activatedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;

  /// Serializes this RoomLight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomLight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomLightCopyWith<RoomLight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomLightCopyWith<$Res> {
  factory $RoomLightCopyWith(RoomLight value, $Res Function(RoomLight) then) =
      _$RoomLightCopyWithImpl<$Res, RoomLight>;
  @useResult
  $Res call({
    String id,
    LightType type,
    String label,
    LightStatus status,
    LightPriority priority,
    String? activatedBy,
    @JsonKey(name: 'activated_by_name') String? activatedByName,
    DateTime? activatedAt,
    String? notes,
    String? iconName,
  });
}

/// @nodoc
class _$RoomLightCopyWithImpl<$Res, $Val extends RoomLight>
    implements $RoomLightCopyWith<$Res> {
  _$RoomLightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomLight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? status = null,
    Object? priority = null,
    Object? activatedBy = freezed,
    Object? activatedByName = freezed,
    Object? activatedAt = freezed,
    Object? notes = freezed,
    Object? iconName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LightType,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LightStatus,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as LightPriority,
            activatedBy: freezed == activatedBy
                ? _value.activatedBy
                : activatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            activatedByName: freezed == activatedByName
                ? _value.activatedByName
                : activatedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            activatedAt: freezed == activatedAt
                ? _value.activatedAt
                : activatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            iconName: freezed == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomLightImplCopyWith<$Res>
    implements $RoomLightCopyWith<$Res> {
  factory _$$RoomLightImplCopyWith(
    _$RoomLightImpl value,
    $Res Function(_$RoomLightImpl) then,
  ) = __$$RoomLightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    LightType type,
    String label,
    LightStatus status,
    LightPriority priority,
    String? activatedBy,
    @JsonKey(name: 'activated_by_name') String? activatedByName,
    DateTime? activatedAt,
    String? notes,
    String? iconName,
  });
}

/// @nodoc
class __$$RoomLightImplCopyWithImpl<$Res>
    extends _$RoomLightCopyWithImpl<$Res, _$RoomLightImpl>
    implements _$$RoomLightImplCopyWith<$Res> {
  __$$RoomLightImplCopyWithImpl(
    _$RoomLightImpl _value,
    $Res Function(_$RoomLightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomLight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? status = null,
    Object? priority = null,
    Object? activatedBy = freezed,
    Object? activatedByName = freezed,
    Object? activatedAt = freezed,
    Object? notes = freezed,
    Object? iconName = freezed,
  }) {
    return _then(
      _$RoomLightImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LightType,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LightStatus,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as LightPriority,
        activatedBy: freezed == activatedBy
            ? _value.activatedBy
            : activatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        activatedByName: freezed == activatedByName
            ? _value.activatedByName
            : activatedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        activatedAt: freezed == activatedAt
            ? _value.activatedAt
            : activatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        iconName: freezed == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomLightImpl extends _RoomLight {
  const _$RoomLightImpl({
    required this.id,
    required this.type,
    required this.label,
    this.status = LightStatus.inactive,
    this.priority = LightPriority.normal,
    this.activatedBy,
    @JsonKey(name: 'activated_by_name') this.activatedByName,
    this.activatedAt,
    this.notes,
    this.iconName,
  }) : super._();

  factory _$RoomLightImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomLightImplFromJson(json);

  @override
  final String id;
  @override
  final LightType type;
  @override
  final String label;
  @override
  @JsonKey()
  final LightStatus status;
  @override
  @JsonKey()
  final LightPriority priority;
  @override
  final String? activatedBy;
  @override
  @JsonKey(name: 'activated_by_name')
  final String? activatedByName;
  @override
  final DateTime? activatedAt;
  @override
  final String? notes;
  @override
  final String? iconName;

  @override
  String toString() {
    return 'RoomLight(id: $id, type: $type, label: $label, status: $status, priority: $priority, activatedBy: $activatedBy, activatedByName: $activatedByName, activatedAt: $activatedAt, notes: $notes, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomLightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.activatedBy, activatedBy) ||
                other.activatedBy == activatedBy) &&
            (identical(other.activatedByName, activatedByName) ||
                other.activatedByName == activatedByName) &&
            (identical(other.activatedAt, activatedAt) ||
                other.activatedAt == activatedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    label,
    status,
    priority,
    activatedBy,
    activatedByName,
    activatedAt,
    notes,
    iconName,
  );

  /// Create a copy of RoomLight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomLightImplCopyWith<_$RoomLightImpl> get copyWith =>
      __$$RoomLightImplCopyWithImpl<_$RoomLightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomLightImplToJson(this);
  }
}

abstract class _RoomLight extends RoomLight {
  const factory _RoomLight({
    required final String id,
    required final LightType type,
    required final String label,
    final LightStatus status,
    final LightPriority priority,
    final String? activatedBy,
    @JsonKey(name: 'activated_by_name') final String? activatedByName,
    final DateTime? activatedAt,
    final String? notes,
    final String? iconName,
  }) = _$RoomLightImpl;
  const _RoomLight._() : super._();

  factory _RoomLight.fromJson(Map<String, dynamic> json) =
      _$RoomLightImpl.fromJson;

  @override
  String get id;
  @override
  LightType get type;
  @override
  String get label;
  @override
  LightStatus get status;
  @override
  LightPriority get priority;
  @override
  String? get activatedBy;
  @override
  @JsonKey(name: 'activated_by_name')
  String? get activatedByName;
  @override
  DateTime? get activatedAt;
  @override
  String? get notes;
  @override
  String? get iconName;

  /// Create a copy of RoomLight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomLightImplCopyWith<_$RoomLightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  RoomStatus get status => throw _privateConstructorUsedError;
  String? get zone => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<RoomLight> get lights => throw _privateConstructorUsedError;
  String? get currentPatientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_patient_name')
  String? get currentPatientName => throw _privateConstructorUsedError;
  String? get assignedStaffId => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_staff_name')
  String? get assignedStaffName => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_activity_at')
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call({
    String id,
    String name,
    String? displayName,
    RoomStatus status,
    String? zone,
    String? location,
    String? description,
    List<RoomLight> lights,
    String? currentPatientId,
    @JsonKey(name: 'current_patient_name') String? currentPatientName,
    String? assignedStaffId,
    @JsonKey(name: 'assigned_staff_name') String? assignedStaffName,
    int? capacity,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = freezed,
    Object? status = null,
    Object? zone = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? lights = null,
    Object? currentPatientId = freezed,
    Object? currentPatientName = freezed,
    Object? assignedStaffId = freezed,
    Object? assignedStaffName = freezed,
    Object? capacity = freezed,
    Object? metadata = freezed,
    Object? lastActivityAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
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
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RoomStatus,
            zone: freezed == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            lights: null == lights
                ? _value.lights
                : lights // ignore: cast_nullable_to_non_nullable
                      as List<RoomLight>,
            currentPatientId: freezed == currentPatientId
                ? _value.currentPatientId
                : currentPatientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentPatientName: freezed == currentPatientName
                ? _value.currentPatientName
                : currentPatientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedStaffId: freezed == assignedStaffId
                ? _value.assignedStaffId
                : assignedStaffId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedStaffName: freezed == assignedStaffName
                ? _value.assignedStaffName
                : assignedStaffName // ignore: cast_nullable_to_non_nullable
                      as String?,
            capacity: freezed == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            lastActivityAt: freezed == lastActivityAt
                ? _value.lastActivityAt
                : lastActivityAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
    _$RoomImpl value,
    $Res Function(_$RoomImpl) then,
  ) = __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? displayName,
    RoomStatus status,
    String? zone,
    String? location,
    String? description,
    List<RoomLight> lights,
    String? currentPatientId,
    @JsonKey(name: 'current_patient_name') String? currentPatientName,
    String? assignedStaffId,
    @JsonKey(name: 'assigned_staff_name') String? assignedStaffName,
    int? capacity,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
    : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = freezed,
    Object? status = null,
    Object? zone = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? lights = null,
    Object? currentPatientId = freezed,
    Object? currentPatientName = freezed,
    Object? assignedStaffId = freezed,
    Object? assignedStaffName = freezed,
    Object? capacity = freezed,
    Object? metadata = freezed,
    Object? lastActivityAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$RoomImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RoomStatus,
        zone: freezed == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        lights: null == lights
            ? _value._lights
            : lights // ignore: cast_nullable_to_non_nullable
                  as List<RoomLight>,
        currentPatientId: freezed == currentPatientId
            ? _value.currentPatientId
            : currentPatientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentPatientName: freezed == currentPatientName
            ? _value.currentPatientName
            : currentPatientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedStaffId: freezed == assignedStaffId
            ? _value.assignedStaffId
            : assignedStaffId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedStaffName: freezed == assignedStaffName
            ? _value.assignedStaffName
            : assignedStaffName // ignore: cast_nullable_to_non_nullable
                  as String?,
        capacity: freezed == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        lastActivityAt: freezed == lastActivityAt
            ? _value.lastActivityAt
            : lastActivityAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$RoomImpl extends _Room {
  const _$RoomImpl({
    required this.id,
    required this.name,
    this.displayName,
    this.status = RoomStatus.available,
    this.zone,
    this.location,
    this.description,
    final List<RoomLight> lights = const [],
    this.currentPatientId,
    @JsonKey(name: 'current_patient_name') this.currentPatientName,
    this.assignedStaffId,
    @JsonKey(name: 'assigned_staff_name') this.assignedStaffName,
    this.capacity,
    final Map<String, dynamic>? metadata,
    @JsonKey(name: 'last_activity_at') this.lastActivityAt,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _lights = lights,
       _metadata = metadata,
       super._();

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? displayName;
  @override
  @JsonKey()
  final RoomStatus status;
  @override
  final String? zone;
  @override
  final String? location;
  @override
  final String? description;
  final List<RoomLight> _lights;
  @override
  @JsonKey()
  List<RoomLight> get lights {
    if (_lights is EqualUnmodifiableListView) return _lights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lights);
  }

  @override
  final String? currentPatientId;
  @override
  @JsonKey(name: 'current_patient_name')
  final String? currentPatientName;
  @override
  final String? assignedStaffId;
  @override
  @JsonKey(name: 'assigned_staff_name')
  final String? assignedStaffName;
  @override
  final int? capacity;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Room(id: $id, name: $name, displayName: $displayName, status: $status, zone: $zone, location: $location, description: $description, lights: $lights, currentPatientId: $currentPatientId, currentPatientName: $currentPatientName, assignedStaffId: $assignedStaffId, assignedStaffName: $assignedStaffName, capacity: $capacity, metadata: $metadata, lastActivityAt: $lastActivityAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._lights, _lights) &&
            (identical(other.currentPatientId, currentPatientId) ||
                other.currentPatientId == currentPatientId) &&
            (identical(other.currentPatientName, currentPatientName) ||
                other.currentPatientName == currentPatientName) &&
            (identical(other.assignedStaffId, assignedStaffId) ||
                other.assignedStaffId == assignedStaffId) &&
            (identical(other.assignedStaffName, assignedStaffName) ||
                other.assignedStaffName == assignedStaffName) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    displayName,
    status,
    zone,
    location,
    description,
    const DeepCollectionEquality().hash(_lights),
    currentPatientId,
    currentPatientName,
    assignedStaffId,
    assignedStaffName,
    capacity,
    const DeepCollectionEquality().hash(_metadata),
    lastActivityAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(this);
  }
}

abstract class _Room extends Room {
  const factory _Room({
    required final String id,
    required final String name,
    final String? displayName,
    final RoomStatus status,
    final String? zone,
    final String? location,
    final String? description,
    final List<RoomLight> lights,
    final String? currentPatientId,
    @JsonKey(name: 'current_patient_name') final String? currentPatientName,
    final String? assignedStaffId,
    @JsonKey(name: 'assigned_staff_name') final String? assignedStaffName,
    final int? capacity,
    final Map<String, dynamic>? metadata,
    @JsonKey(name: 'last_activity_at') final DateTime? lastActivityAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$RoomImpl;
  const _Room._() : super._();

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get displayName;
  @override
  RoomStatus get status;
  @override
  String? get zone;
  @override
  String? get location;
  @override
  String? get description;
  @override
  List<RoomLight> get lights;
  @override
  String? get currentPatientId;
  @override
  @JsonKey(name: 'current_patient_name')
  String? get currentPatientName;
  @override
  String? get assignedStaffId;
  @override
  @JsonKey(name: 'assigned_staff_name')
  String? get assignedStaffName;
  @override
  int? get capacity;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(name: 'last_activity_at')
  DateTime? get lastActivityAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoomZone _$RoomZoneFromJson(Map<String, dynamic> json) {
  return _RoomZone.fromJson(json);
}

/// @nodoc
mixin _$RoomZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get roomCount => throw _privateConstructorUsedError;

  /// Serializes this RoomZone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomZoneCopyWith<RoomZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomZoneCopyWith<$Res> {
  factory $RoomZoneCopyWith(RoomZone value, $Res Function(RoomZone) then) =
      _$RoomZoneCopyWithImpl<$Res, RoomZone>;
  @useResult
  $Res call({String id, String name, String? description, int roomCount});
}

/// @nodoc
class _$RoomZoneCopyWithImpl<$Res, $Val extends RoomZone>
    implements $RoomZoneCopyWith<$Res> {
  _$RoomZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomCount = null,
  }) {
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            roomCount: null == roomCount
                ? _value.roomCount
                : roomCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomZoneImplCopyWith<$Res>
    implements $RoomZoneCopyWith<$Res> {
  factory _$$RoomZoneImplCopyWith(
    _$RoomZoneImpl value,
    $Res Function(_$RoomZoneImpl) then,
  ) = __$$RoomZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? description, int roomCount});
}

/// @nodoc
class __$$RoomZoneImplCopyWithImpl<$Res>
    extends _$RoomZoneCopyWithImpl<$Res, _$RoomZoneImpl>
    implements _$$RoomZoneImplCopyWith<$Res> {
  __$$RoomZoneImplCopyWithImpl(
    _$RoomZoneImpl _value,
    $Res Function(_$RoomZoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomCount = null,
  }) {
    return _then(
      _$RoomZoneImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        roomCount: null == roomCount
            ? _value.roomCount
            : roomCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomZoneImpl implements _RoomZone {
  const _$RoomZoneImpl({
    required this.id,
    required this.name,
    this.description,
    this.roomCount = 0,
  });

  factory _$RoomZoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomZoneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final int roomCount;

  @override
  String toString() {
    return 'RoomZone(id: $id, name: $name, description: $description, roomCount: $roomCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.roomCount, roomCount) ||
                other.roomCount == roomCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, roomCount);

  /// Create a copy of RoomZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomZoneImplCopyWith<_$RoomZoneImpl> get copyWith =>
      __$$RoomZoneImplCopyWithImpl<_$RoomZoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomZoneImplToJson(this);
  }
}

abstract class _RoomZone implements RoomZone {
  const factory _RoomZone({
    required final String id,
    required final String name,
    final String? description,
    final int roomCount,
  }) = _$RoomZoneImpl;

  factory _RoomZone.fromJson(Map<String, dynamic> json) =
      _$RoomZoneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get roomCount;

  /// Create a copy of RoomZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomZoneImplCopyWith<_$RoomZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
