// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StaffSchedule _$StaffScheduleFromJson(Map<String, dynamic> json) {
  return _StaffSchedule.fromJson(json);
}

/// @nodoc
mixin _$StaffSchedule {
  String get id => throw _privateConstructorUsedError;
  String get staffId => throw _privateConstructorUsedError;
  DateTime get shiftStart => throw _privateConstructorUsedError;
  DateTime get shiftEnd => throw _privateConstructorUsedError;
  ShiftType get shiftType => throw _privateConstructorUsedError;
  AvailabilityStatus get status => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get breakStart => throw _privateConstructorUsedError;
  DateTime? get breakEnd => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StaffSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaffSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaffScheduleCopyWith<StaffSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaffScheduleCopyWith<$Res> {
  factory $StaffScheduleCopyWith(
    StaffSchedule value,
    $Res Function(StaffSchedule) then,
  ) = _$StaffScheduleCopyWithImpl<$Res, StaffSchedule>;
  @useResult
  $Res call({
    String id,
    String staffId,
    DateTime shiftStart,
    DateTime shiftEnd,
    ShiftType shiftType,
    AvailabilityStatus status,
    String? location,
    String? department,
    String? notes,
    DateTime? breakStart,
    DateTime? breakEnd,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$StaffScheduleCopyWithImpl<$Res, $Val extends StaffSchedule>
    implements $StaffScheduleCopyWith<$Res> {
  _$StaffScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaffSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? shiftStart = null,
    Object? shiftEnd = null,
    Object? shiftType = null,
    Object? status = null,
    Object? location = freezed,
    Object? department = freezed,
    Object? notes = freezed,
    Object? breakStart = freezed,
    Object? breakEnd = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            staffId: null == staffId
                ? _value.staffId
                : staffId // ignore: cast_nullable_to_non_nullable
                      as String,
            shiftStart: null == shiftStart
                ? _value.shiftStart
                : shiftStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            shiftEnd: null == shiftEnd
                ? _value.shiftEnd
                : shiftEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            shiftType: null == shiftType
                ? _value.shiftType
                : shiftType // ignore: cast_nullable_to_non_nullable
                      as ShiftType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AvailabilityStatus,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            breakStart: freezed == breakStart
                ? _value.breakStart
                : breakStart // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            breakEnd: freezed == breakEnd
                ? _value.breakEnd
                : breakEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$StaffScheduleImplCopyWith<$Res>
    implements $StaffScheduleCopyWith<$Res> {
  factory _$$StaffScheduleImplCopyWith(
    _$StaffScheduleImpl value,
    $Res Function(_$StaffScheduleImpl) then,
  ) = __$$StaffScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String staffId,
    DateTime shiftStart,
    DateTime shiftEnd,
    ShiftType shiftType,
    AvailabilityStatus status,
    String? location,
    String? department,
    String? notes,
    DateTime? breakStart,
    DateTime? breakEnd,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$StaffScheduleImplCopyWithImpl<$Res>
    extends _$StaffScheduleCopyWithImpl<$Res, _$StaffScheduleImpl>
    implements _$$StaffScheduleImplCopyWith<$Res> {
  __$$StaffScheduleImplCopyWithImpl(
    _$StaffScheduleImpl _value,
    $Res Function(_$StaffScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StaffSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? shiftStart = null,
    Object? shiftEnd = null,
    Object? shiftType = null,
    Object? status = null,
    Object? location = freezed,
    Object? department = freezed,
    Object? notes = freezed,
    Object? breakStart = freezed,
    Object? breakEnd = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$StaffScheduleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        staffId: null == staffId
            ? _value.staffId
            : staffId // ignore: cast_nullable_to_non_nullable
                  as String,
        shiftStart: null == shiftStart
            ? _value.shiftStart
            : shiftStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        shiftEnd: null == shiftEnd
            ? _value.shiftEnd
            : shiftEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        shiftType: null == shiftType
            ? _value.shiftType
            : shiftType // ignore: cast_nullable_to_non_nullable
                  as ShiftType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AvailabilityStatus,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        breakStart: freezed == breakStart
            ? _value.breakStart
            : breakStart // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        breakEnd: freezed == breakEnd
            ? _value.breakEnd
            : breakEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$StaffScheduleImpl extends _StaffSchedule {
  const _$StaffScheduleImpl({
    required this.id,
    required this.staffId,
    required this.shiftStart,
    required this.shiftEnd,
    this.shiftType = ShiftType.morning,
    this.status = AvailabilityStatus.available,
    this.location,
    this.department,
    this.notes,
    this.breakStart,
    this.breakEnd,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$StaffScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaffScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String staffId;
  @override
  final DateTime shiftStart;
  @override
  final DateTime shiftEnd;
  @override
  @JsonKey()
  final ShiftType shiftType;
  @override
  @JsonKey()
  final AvailabilityStatus status;
  @override
  final String? location;
  @override
  final String? department;
  @override
  final String? notes;
  @override
  final DateTime? breakStart;
  @override
  final DateTime? breakEnd;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StaffSchedule(id: $id, staffId: $staffId, shiftStart: $shiftStart, shiftEnd: $shiftEnd, shiftType: $shiftType, status: $status, location: $location, department: $department, notes: $notes, breakStart: $breakStart, breakEnd: $breakEnd, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaffScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.shiftStart, shiftStart) ||
                other.shiftStart == shiftStart) &&
            (identical(other.shiftEnd, shiftEnd) ||
                other.shiftEnd == shiftEnd) &&
            (identical(other.shiftType, shiftType) ||
                other.shiftType == shiftType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.breakStart, breakStart) ||
                other.breakStart == breakStart) &&
            (identical(other.breakEnd, breakEnd) ||
                other.breakEnd == breakEnd) &&
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
    staffId,
    shiftStart,
    shiftEnd,
    shiftType,
    status,
    location,
    department,
    notes,
    breakStart,
    breakEnd,
    createdAt,
    updatedAt,
  );

  /// Create a copy of StaffSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaffScheduleImplCopyWith<_$StaffScheduleImpl> get copyWith =>
      __$$StaffScheduleImplCopyWithImpl<_$StaffScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaffScheduleImplToJson(this);
  }
}

abstract class _StaffSchedule extends StaffSchedule {
  const factory _StaffSchedule({
    required final String id,
    required final String staffId,
    required final DateTime shiftStart,
    required final DateTime shiftEnd,
    final ShiftType shiftType,
    final AvailabilityStatus status,
    final String? location,
    final String? department,
    final String? notes,
    final DateTime? breakStart,
    final DateTime? breakEnd,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$StaffScheduleImpl;
  const _StaffSchedule._() : super._();

  factory _StaffSchedule.fromJson(Map<String, dynamic> json) =
      _$StaffScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get staffId;
  @override
  DateTime get shiftStart;
  @override
  DateTime get shiftEnd;
  @override
  ShiftType get shiftType;
  @override
  AvailabilityStatus get status;
  @override
  String? get location;
  @override
  String? get department;
  @override
  String? get notes;
  @override
  DateTime? get breakStart;
  @override
  DateTime? get breakEnd;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of StaffSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaffScheduleImplCopyWith<_$StaffScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) {
  return _StaffMember.fromJson(json);
}

/// @nodoc
mixin _$StaffMember {
  User get user => throw _privateConstructorUsedError;
  List<String> get departments => throw _privateConstructorUsedError;
  List<String> get specializations => throw _privateConstructorUsedError;
  List<String> get certifications => throw _privateConstructorUsedError;
  StaffSchedule? get currentSchedule => throw _privateConstructorUsedError;
  AvailabilityStatus get currentStatus => throw _privateConstructorUsedError;
  String? get currentLocation => throw _privateConstructorUsedError;
  int? get patientCount => throw _privateConstructorUsedError;
  DateTime? get lastStatusUpdate => throw _privateConstructorUsedError;

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaffMemberCopyWith<StaffMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaffMemberCopyWith<$Res> {
  factory $StaffMemberCopyWith(
    StaffMember value,
    $Res Function(StaffMember) then,
  ) = _$StaffMemberCopyWithImpl<$Res, StaffMember>;
  @useResult
  $Res call({
    User user,
    List<String> departments,
    List<String> specializations,
    List<String> certifications,
    StaffSchedule? currentSchedule,
    AvailabilityStatus currentStatus,
    String? currentLocation,
    int? patientCount,
    DateTime? lastStatusUpdate,
  });

  $UserCopyWith<$Res> get user;
  $StaffScheduleCopyWith<$Res>? get currentSchedule;
}

/// @nodoc
class _$StaffMemberCopyWithImpl<$Res, $Val extends StaffMember>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? departments = null,
    Object? specializations = null,
    Object? certifications = null,
    Object? currentSchedule = freezed,
    Object? currentStatus = null,
    Object? currentLocation = freezed,
    Object? patientCount = freezed,
    Object? lastStatusUpdate = freezed,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            departments: null == departments
                ? _value.departments
                : departments // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            specializations: null == specializations
                ? _value.specializations
                : specializations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            certifications: null == certifications
                ? _value.certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            currentSchedule: freezed == currentSchedule
                ? _value.currentSchedule
                : currentSchedule // ignore: cast_nullable_to_non_nullable
                      as StaffSchedule?,
            currentStatus: null == currentStatus
                ? _value.currentStatus
                : currentStatus // ignore: cast_nullable_to_non_nullable
                      as AvailabilityStatus,
            currentLocation: freezed == currentLocation
                ? _value.currentLocation
                : currentLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientCount: freezed == patientCount
                ? _value.patientCount
                : patientCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            lastStatusUpdate: freezed == lastStatusUpdate
                ? _value.lastStatusUpdate
                : lastStatusUpdate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StaffScheduleCopyWith<$Res>? get currentSchedule {
    if (_value.currentSchedule == null) {
      return null;
    }

    return $StaffScheduleCopyWith<$Res>(_value.currentSchedule!, (value) {
      return _then(_value.copyWith(currentSchedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StaffMemberImplCopyWith<$Res>
    implements $StaffMemberCopyWith<$Res> {
  factory _$$StaffMemberImplCopyWith(
    _$StaffMemberImpl value,
    $Res Function(_$StaffMemberImpl) then,
  ) = __$$StaffMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    User user,
    List<String> departments,
    List<String> specializations,
    List<String> certifications,
    StaffSchedule? currentSchedule,
    AvailabilityStatus currentStatus,
    String? currentLocation,
    int? patientCount,
    DateTime? lastStatusUpdate,
  });

  @override
  $UserCopyWith<$Res> get user;
  @override
  $StaffScheduleCopyWith<$Res>? get currentSchedule;
}

/// @nodoc
class __$$StaffMemberImplCopyWithImpl<$Res>
    extends _$StaffMemberCopyWithImpl<$Res, _$StaffMemberImpl>
    implements _$$StaffMemberImplCopyWith<$Res> {
  __$$StaffMemberImplCopyWithImpl(
    _$StaffMemberImpl _value,
    $Res Function(_$StaffMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? departments = null,
    Object? specializations = null,
    Object? certifications = null,
    Object? currentSchedule = freezed,
    Object? currentStatus = null,
    Object? currentLocation = freezed,
    Object? patientCount = freezed,
    Object? lastStatusUpdate = freezed,
  }) {
    return _then(
      _$StaffMemberImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        departments: null == departments
            ? _value._departments
            : departments // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        specializations: null == specializations
            ? _value._specializations
            : specializations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        certifications: null == certifications
            ? _value._certifications
            : certifications // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        currentSchedule: freezed == currentSchedule
            ? _value.currentSchedule
            : currentSchedule // ignore: cast_nullable_to_non_nullable
                  as StaffSchedule?,
        currentStatus: null == currentStatus
            ? _value.currentStatus
            : currentStatus // ignore: cast_nullable_to_non_nullable
                  as AvailabilityStatus,
        currentLocation: freezed == currentLocation
            ? _value.currentLocation
            : currentLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientCount: freezed == patientCount
            ? _value.patientCount
            : patientCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        lastStatusUpdate: freezed == lastStatusUpdate
            ? _value.lastStatusUpdate
            : lastStatusUpdate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StaffMemberImpl extends _StaffMember {
  const _$StaffMemberImpl({
    required this.user,
    final List<String> departments = const [],
    final List<String> specializations = const [],
    final List<String> certifications = const [],
    this.currentSchedule,
    this.currentStatus = AvailabilityStatus.available,
    this.currentLocation,
    this.patientCount,
    this.lastStatusUpdate,
  }) : _departments = departments,
       _specializations = specializations,
       _certifications = certifications,
       super._();

  factory _$StaffMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaffMemberImplFromJson(json);

  @override
  final User user;
  final List<String> _departments;
  @override
  @JsonKey()
  List<String> get departments {
    if (_departments is EqualUnmodifiableListView) return _departments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_departments);
  }

  final List<String> _specializations;
  @override
  @JsonKey()
  List<String> get specializations {
    if (_specializations is EqualUnmodifiableListView) return _specializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specializations);
  }

  final List<String> _certifications;
  @override
  @JsonKey()
  List<String> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  @override
  final StaffSchedule? currentSchedule;
  @override
  @JsonKey()
  final AvailabilityStatus currentStatus;
  @override
  final String? currentLocation;
  @override
  final int? patientCount;
  @override
  final DateTime? lastStatusUpdate;

  @override
  String toString() {
    return 'StaffMember(user: $user, departments: $departments, specializations: $specializations, certifications: $certifications, currentSchedule: $currentSchedule, currentStatus: $currentStatus, currentLocation: $currentLocation, patientCount: $patientCount, lastStatusUpdate: $lastStatusUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaffMemberImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(
              other._departments,
              _departments,
            ) &&
            const DeepCollectionEquality().equals(
              other._specializations,
              _specializations,
            ) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.currentSchedule, currentSchedule) ||
                other.currentSchedule == currentSchedule) &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation) &&
            (identical(other.patientCount, patientCount) ||
                other.patientCount == patientCount) &&
            (identical(other.lastStatusUpdate, lastStatusUpdate) ||
                other.lastStatusUpdate == lastStatusUpdate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    const DeepCollectionEquality().hash(_departments),
    const DeepCollectionEquality().hash(_specializations),
    const DeepCollectionEquality().hash(_certifications),
    currentSchedule,
    currentStatus,
    currentLocation,
    patientCount,
    lastStatusUpdate,
  );

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaffMemberImplCopyWith<_$StaffMemberImpl> get copyWith =>
      __$$StaffMemberImplCopyWithImpl<_$StaffMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaffMemberImplToJson(this);
  }
}

abstract class _StaffMember extends StaffMember {
  const factory _StaffMember({
    required final User user,
    final List<String> departments,
    final List<String> specializations,
    final List<String> certifications,
    final StaffSchedule? currentSchedule,
    final AvailabilityStatus currentStatus,
    final String? currentLocation,
    final int? patientCount,
    final DateTime? lastStatusUpdate,
  }) = _$StaffMemberImpl;
  const _StaffMember._() : super._();

  factory _StaffMember.fromJson(Map<String, dynamic> json) =
      _$StaffMemberImpl.fromJson;

  @override
  User get user;
  @override
  List<String> get departments;
  @override
  List<String> get specializations;
  @override
  List<String> get certifications;
  @override
  StaffSchedule? get currentSchedule;
  @override
  AvailabilityStatus get currentStatus;
  @override
  String? get currentLocation;
  @override
  int? get patientCount;
  @override
  DateTime? get lastStatusUpdate;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaffMemberImplCopyWith<_$StaffMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StaffActivity _$StaffActivityFromJson(Map<String, dynamic> json) {
  return _StaffActivity.fromJson(json);
}

/// @nodoc
mixin _$StaffActivity {
  String get id => throw _privateConstructorUsedError;
  String get staffId => throw _privateConstructorUsedError;
  String get activityType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get patientId => throw _privateConstructorUsedError;
  String? get patientName => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StaffActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaffActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaffActivityCopyWith<StaffActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaffActivityCopyWith<$Res> {
  factory $StaffActivityCopyWith(
    StaffActivity value,
    $Res Function(StaffActivity) then,
  ) = _$StaffActivityCopyWithImpl<$Res, StaffActivity>;
  @useResult
  $Res call({
    String id,
    String staffId,
    String activityType,
    String description,
    String? patientId,
    String? patientName,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool isCompleted,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$StaffActivityCopyWithImpl<$Res, $Val extends StaffActivity>
    implements $StaffActivityCopyWith<$Res> {
  _$StaffActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaffActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? activityType = null,
    Object? description = null,
    Object? patientId = freezed,
    Object? patientName = freezed,
    Object? location = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isCompleted = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            staffId: null == staffId
                ? _value.staffId
                : staffId // ignore: cast_nullable_to_non_nullable
                      as String,
            activityType: null == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: freezed == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientName: freezed == patientName
                ? _value.patientName
                : patientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StaffActivityImplCopyWith<$Res>
    implements $StaffActivityCopyWith<$Res> {
  factory _$$StaffActivityImplCopyWith(
    _$StaffActivityImpl value,
    $Res Function(_$StaffActivityImpl) then,
  ) = __$$StaffActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String staffId,
    String activityType,
    String description,
    String? patientId,
    String? patientName,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool isCompleted,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$StaffActivityImplCopyWithImpl<$Res>
    extends _$StaffActivityCopyWithImpl<$Res, _$StaffActivityImpl>
    implements _$$StaffActivityImplCopyWith<$Res> {
  __$$StaffActivityImplCopyWithImpl(
    _$StaffActivityImpl _value,
    $Res Function(_$StaffActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StaffActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? activityType = null,
    Object? description = null,
    Object? patientId = freezed,
    Object? patientName = freezed,
    Object? location = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isCompleted = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$StaffActivityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        staffId: null == staffId
            ? _value.staffId
            : staffId // ignore: cast_nullable_to_non_nullable
                  as String,
        activityType: null == activityType
            ? _value.activityType
            : activityType // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: freezed == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientName: freezed == patientName
            ? _value.patientName
            : patientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StaffActivityImpl implements _StaffActivity {
  const _$StaffActivityImpl({
    required this.id,
    required this.staffId,
    required this.activityType,
    required this.description,
    this.patientId,
    this.patientName,
    this.location,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
  });

  factory _$StaffActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaffActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String staffId;
  @override
  final String activityType;
  @override
  final String description;
  @override
  final String? patientId;
  @override
  final String? patientName;
  @override
  final String? location;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StaffActivity(id: $id, staffId: $staffId, activityType: $activityType, description: $description, patientId: $patientId, patientName: $patientName, location: $location, startTime: $startTime, endTime: $endTime, isCompleted: $isCompleted, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaffActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    staffId,
    activityType,
    description,
    patientId,
    patientName,
    location,
    startTime,
    endTime,
    isCompleted,
    notes,
    createdAt,
  );

  /// Create a copy of StaffActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaffActivityImplCopyWith<_$StaffActivityImpl> get copyWith =>
      __$$StaffActivityImplCopyWithImpl<_$StaffActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaffActivityImplToJson(this);
  }
}

abstract class _StaffActivity implements StaffActivity {
  const factory _StaffActivity({
    required final String id,
    required final String staffId,
    required final String activityType,
    required final String description,
    final String? patientId,
    final String? patientName,
    final String? location,
    final DateTime? startTime,
    final DateTime? endTime,
    final bool isCompleted,
    final String? notes,
    required final DateTime createdAt,
  }) = _$StaffActivityImpl;

  factory _StaffActivity.fromJson(Map<String, dynamic> json) =
      _$StaffActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get staffId;
  @override
  String get activityType;
  @override
  String get description;
  @override
  String? get patientId;
  @override
  String? get patientName;
  @override
  String? get location;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  bool get isCompleted;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of StaffActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaffActivityImplCopyWith<_$StaffActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateAvailabilityRequest _$UpdateAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateAvailabilityRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateAvailabilityRequest {
  String get staffId => throw _privateConstructorUsedError;
  AvailabilityStatus get status => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this UpdateAvailabilityRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateAvailabilityRequestCopyWith<UpdateAvailabilityRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateAvailabilityRequestCopyWith<$Res> {
  factory $UpdateAvailabilityRequestCopyWith(
    UpdateAvailabilityRequest value,
    $Res Function(UpdateAvailabilityRequest) then,
  ) = _$UpdateAvailabilityRequestCopyWithImpl<$Res, UpdateAvailabilityRequest>;
  @useResult
  $Res call({
    String staffId,
    AvailabilityStatus status,
    String? location,
    String? notes,
  });
}

/// @nodoc
class _$UpdateAvailabilityRequestCopyWithImpl<
  $Res,
  $Val extends UpdateAvailabilityRequest
>
    implements $UpdateAvailabilityRequestCopyWith<$Res> {
  _$UpdateAvailabilityRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? staffId = null,
    Object? status = null,
    Object? location = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            staffId: null == staffId
                ? _value.staffId
                : staffId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AvailabilityStatus,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$UpdateAvailabilityRequestImplCopyWith<$Res>
    implements $UpdateAvailabilityRequestCopyWith<$Res> {
  factory _$$UpdateAvailabilityRequestImplCopyWith(
    _$UpdateAvailabilityRequestImpl value,
    $Res Function(_$UpdateAvailabilityRequestImpl) then,
  ) = __$$UpdateAvailabilityRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String staffId,
    AvailabilityStatus status,
    String? location,
    String? notes,
  });
}

/// @nodoc
class __$$UpdateAvailabilityRequestImplCopyWithImpl<$Res>
    extends
        _$UpdateAvailabilityRequestCopyWithImpl<
          $Res,
          _$UpdateAvailabilityRequestImpl
        >
    implements _$$UpdateAvailabilityRequestImplCopyWith<$Res> {
  __$$UpdateAvailabilityRequestImplCopyWithImpl(
    _$UpdateAvailabilityRequestImpl _value,
    $Res Function(_$UpdateAvailabilityRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? staffId = null,
    Object? status = null,
    Object? location = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$UpdateAvailabilityRequestImpl(
        staffId: null == staffId
            ? _value.staffId
            : staffId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AvailabilityStatus,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$UpdateAvailabilityRequestImpl implements _UpdateAvailabilityRequest {
  const _$UpdateAvailabilityRequestImpl({
    required this.staffId,
    required this.status,
    this.location,
    this.notes,
  });

  factory _$UpdateAvailabilityRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateAvailabilityRequestImplFromJson(json);

  @override
  final String staffId;
  @override
  final AvailabilityStatus status;
  @override
  final String? location;
  @override
  final String? notes;

  @override
  String toString() {
    return 'UpdateAvailabilityRequest(staffId: $staffId, status: $status, location: $location, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAvailabilityRequestImpl &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, staffId, status, location, notes);

  /// Create a copy of UpdateAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAvailabilityRequestImplCopyWith<_$UpdateAvailabilityRequestImpl>
  get copyWith =>
      __$$UpdateAvailabilityRequestImplCopyWithImpl<
        _$UpdateAvailabilityRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateAvailabilityRequestImplToJson(this);
  }
}

abstract class _UpdateAvailabilityRequest implements UpdateAvailabilityRequest {
  const factory _UpdateAvailabilityRequest({
    required final String staffId,
    required final AvailabilityStatus status,
    final String? location,
    final String? notes,
  }) = _$UpdateAvailabilityRequestImpl;

  factory _UpdateAvailabilityRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateAvailabilityRequestImpl.fromJson;

  @override
  String get staffId;
  @override
  AvailabilityStatus get status;
  @override
  String? get location;
  @override
  String? get notes;

  /// Create a copy of UpdateAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAvailabilityRequestImplCopyWith<_$UpdateAvailabilityRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
