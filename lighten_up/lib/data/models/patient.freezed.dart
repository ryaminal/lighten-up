// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get medicalRecordNumber => throw _privateConstructorUsedError;
  PatientStatus get status => throw _privateConstructorUsedError;
  PatientPriority get priority => throw _privateConstructorUsedError;
  String? get roomNumber => throw _privateConstructorUsedError;
  String? get bedNumber => throw _privateConstructorUsedError;
  String? get wardLocation => throw _privateConstructorUsedError;
  String? get primaryPhysicianId => throw _privateConstructorUsedError;
  String? get primaryPhysicianName => throw _privateConstructorUsedError;
  String? get primaryNurseId => throw _privateConstructorUsedError;
  String? get primaryNurseName => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get medications => throw _privateConstructorUsedError;
  List<String> get conditions => throw _privateConstructorUsedError;
  String? get insuranceProvider => throw _privateConstructorUsedError;
  String? get insurancePolicyNumber => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get admissionDate => throw _privateConstructorUsedError;
  DateTime? get dischargeDate => throw _privateConstructorUsedError;
  DateTime? get lastVisitDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String? middleName,
    DateTime dateOfBirth,
    String gender,
    String? photoUrl,
    String? medicalRecordNumber,
    PatientStatus status,
    PatientPriority priority,
    String? roomNumber,
    String? bedNumber,
    String? wardLocation,
    String? primaryPhysicianId,
    String? primaryPhysicianName,
    String? primaryNurseId,
    String? primaryNurseName,
    String? bloodType,
    List<String> allergies,
    List<String> medications,
    List<String> conditions,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    DateTime? lastVisitDate,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? middleName = freezed,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? photoUrl = freezed,
    Object? medicalRecordNumber = freezed,
    Object? status = null,
    Object? priority = null,
    Object? roomNumber = freezed,
    Object? bedNumber = freezed,
    Object? wardLocation = freezed,
    Object? primaryPhysicianId = freezed,
    Object? primaryPhysicianName = freezed,
    Object? primaryNurseId = freezed,
    Object? primaryNurseName = freezed,
    Object? bloodType = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? conditions = null,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? admissionDate = freezed,
    Object? dischargeDate = freezed,
    Object? lastVisitDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            middleName: freezed == middleName
                ? _value.middleName
                : middleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            medicalRecordNumber: freezed == medicalRecordNumber
                ? _value.medicalRecordNumber
                : medicalRecordNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PatientStatus,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as PatientPriority,
            roomNumber: freezed == roomNumber
                ? _value.roomNumber
                : roomNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            bedNumber: freezed == bedNumber
                ? _value.bedNumber
                : bedNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            wardLocation: freezed == wardLocation
                ? _value.wardLocation
                : wardLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPhysicianId: freezed == primaryPhysicianId
                ? _value.primaryPhysicianId
                : primaryPhysicianId // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPhysicianName: freezed == primaryPhysicianName
                ? _value.primaryPhysicianName
                : primaryPhysicianName // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryNurseId: freezed == primaryNurseId
                ? _value.primaryNurseId
                : primaryNurseId // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryNurseName: freezed == primaryNurseName
                ? _value.primaryNurseName
                : primaryNurseName // ignore: cast_nullable_to_non_nullable
                      as String?,
            bloodType: freezed == bloodType
                ? _value.bloodType
                : bloodType // ignore: cast_nullable_to_non_nullable
                      as String?,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            medications: null == medications
                ? _value.medications
                : medications // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            conditions: null == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            insuranceProvider: freezed == insuranceProvider
                ? _value.insuranceProvider
                : insuranceProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            insurancePolicyNumber: freezed == insurancePolicyNumber
                ? _value.insurancePolicyNumber
                : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactName: freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactPhone: freezed == emergencyContactPhone
                ? _value.emergencyContactPhone
                : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            admissionDate: freezed == admissionDate
                ? _value.admissionDate
                : admissionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dischargeDate: freezed == dischargeDate
                ? _value.dischargeDate
                : dischargeDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastVisitDate: freezed == lastVisitDate
                ? _value.lastVisitDate
                : lastVisitDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
    _$PatientImpl value,
    $Res Function(_$PatientImpl) then,
  ) = __$$PatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String? middleName,
    DateTime dateOfBirth,
    String gender,
    String? photoUrl,
    String? medicalRecordNumber,
    PatientStatus status,
    PatientPriority priority,
    String? roomNumber,
    String? bedNumber,
    String? wardLocation,
    String? primaryPhysicianId,
    String? primaryPhysicianName,
    String? primaryNurseId,
    String? primaryNurseName,
    String? bloodType,
    List<String> allergies,
    List<String> medications,
    List<String> conditions,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    DateTime? lastVisitDate,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
    _$PatientImpl _value,
    $Res Function(_$PatientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? middleName = freezed,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? photoUrl = freezed,
    Object? medicalRecordNumber = freezed,
    Object? status = null,
    Object? priority = null,
    Object? roomNumber = freezed,
    Object? bedNumber = freezed,
    Object? wardLocation = freezed,
    Object? primaryPhysicianId = freezed,
    Object? primaryPhysicianName = freezed,
    Object? primaryNurseId = freezed,
    Object? primaryNurseName = freezed,
    Object? bloodType = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? conditions = null,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? admissionDate = freezed,
    Object? dischargeDate = freezed,
    Object? lastVisitDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PatientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        middleName: freezed == middleName
            ? _value.middleName
            : middleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        medicalRecordNumber: freezed == medicalRecordNumber
            ? _value.medicalRecordNumber
            : medicalRecordNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PatientStatus,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as PatientPriority,
        roomNumber: freezed == roomNumber
            ? _value.roomNumber
            : roomNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        bedNumber: freezed == bedNumber
            ? _value.bedNumber
            : bedNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        wardLocation: freezed == wardLocation
            ? _value.wardLocation
            : wardLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPhysicianId: freezed == primaryPhysicianId
            ? _value.primaryPhysicianId
            : primaryPhysicianId // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPhysicianName: freezed == primaryPhysicianName
            ? _value.primaryPhysicianName
            : primaryPhysicianName // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryNurseId: freezed == primaryNurseId
            ? _value.primaryNurseId
            : primaryNurseId // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryNurseName: freezed == primaryNurseName
            ? _value.primaryNurseName
            : primaryNurseName // ignore: cast_nullable_to_non_nullable
                  as String?,
        bloodType: freezed == bloodType
            ? _value.bloodType
            : bloodType // ignore: cast_nullable_to_non_nullable
                  as String?,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        medications: null == medications
            ? _value._medications
            : medications // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        conditions: null == conditions
            ? _value._conditions
            : conditions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        insuranceProvider: freezed == insuranceProvider
            ? _value.insuranceProvider
            : insuranceProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        insurancePolicyNumber: freezed == insurancePolicyNumber
            ? _value.insurancePolicyNumber
            : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactName: freezed == emergencyContactName
            ? _value.emergencyContactName
            : emergencyContactName // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactPhone: freezed == emergencyContactPhone
            ? _value.emergencyContactPhone
            : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        admissionDate: freezed == admissionDate
            ? _value.admissionDate
            : admissionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dischargeDate: freezed == dischargeDate
            ? _value.dischargeDate
            : dischargeDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastVisitDate: freezed == lastVisitDate
            ? _value.lastVisitDate
            : lastVisitDate // ignore: cast_nullable_to_non_nullable
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
class _$PatientImpl extends _Patient {
  const _$PatientImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    this.medicalRecordNumber,
    this.status = PatientStatus.active,
    this.priority = PatientPriority.routine,
    this.roomNumber,
    this.bedNumber,
    this.wardLocation,
    this.primaryPhysicianId,
    this.primaryPhysicianName,
    this.primaryNurseId,
    this.primaryNurseName,
    this.bloodType,
    final List<String> allergies = const [],
    final List<String> medications = const [],
    final List<String> conditions = const [],
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    final Map<String, dynamic>? metadata,
    this.admissionDate,
    this.dischargeDate,
    this.lastVisitDate,
    required this.createdAt,
    this.updatedAt,
  }) : _allergies = allergies,
       _medications = medications,
       _conditions = conditions,
       _metadata = metadata,
       super._();

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? middleName;
  @override
  final DateTime dateOfBirth;
  @override
  final String gender;
  @override
  final String? photoUrl;
  @override
  final String? medicalRecordNumber;
  @override
  @JsonKey()
  final PatientStatus status;
  @override
  @JsonKey()
  final PatientPriority priority;
  @override
  final String? roomNumber;
  @override
  final String? bedNumber;
  @override
  final String? wardLocation;
  @override
  final String? primaryPhysicianId;
  @override
  final String? primaryPhysicianName;
  @override
  final String? primaryNurseId;
  @override
  final String? primaryNurseName;
  @override
  final String? bloodType;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _medications;
  @override
  @JsonKey()
  List<String> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  final List<String> _conditions;
  @override
  @JsonKey()
  List<String> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @override
  final String? insuranceProvider;
  @override
  final String? insurancePolicyNumber;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
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

  @override
  final DateTime? admissionDate;
  @override
  final DateTime? dischargeDate;
  @override
  final DateTime? lastVisitDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, middleName: $middleName, dateOfBirth: $dateOfBirth, gender: $gender, photoUrl: $photoUrl, medicalRecordNumber: $medicalRecordNumber, status: $status, priority: $priority, roomNumber: $roomNumber, bedNumber: $bedNumber, wardLocation: $wardLocation, primaryPhysicianId: $primaryPhysicianId, primaryPhysicianName: $primaryPhysicianName, primaryNurseId: $primaryNurseId, primaryNurseName: $primaryNurseName, bloodType: $bloodType, allergies: $allergies, medications: $medications, conditions: $conditions, insuranceProvider: $insuranceProvider, insurancePolicyNumber: $insurancePolicyNumber, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, notes: $notes, metadata: $metadata, admissionDate: $admissionDate, dischargeDate: $dischargeDate, lastVisitDate: $lastVisitDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.medicalRecordNumber, medicalRecordNumber) ||
                other.medicalRecordNumber == medicalRecordNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.bedNumber, bedNumber) ||
                other.bedNumber == bedNumber) &&
            (identical(other.wardLocation, wardLocation) ||
                other.wardLocation == wardLocation) &&
            (identical(other.primaryPhysicianId, primaryPhysicianId) ||
                other.primaryPhysicianId == primaryPhysicianId) &&
            (identical(other.primaryPhysicianName, primaryPhysicianName) ||
                other.primaryPhysicianName == primaryPhysicianName) &&
            (identical(other.primaryNurseId, primaryNurseId) ||
                other.primaryNurseId == primaryNurseId) &&
            (identical(other.primaryNurseName, primaryNurseName) ||
                other.primaryNurseName == primaryNurseName) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ) &&
            (identical(other.insuranceProvider, insuranceProvider) ||
                other.insuranceProvider == insuranceProvider) &&
            (identical(other.insurancePolicyNumber, insurancePolicyNumber) ||
                other.insurancePolicyNumber == insurancePolicyNumber) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.admissionDate, admissionDate) ||
                other.admissionDate == admissionDate) &&
            (identical(other.dischargeDate, dischargeDate) ||
                other.dischargeDate == dischargeDate) &&
            (identical(other.lastVisitDate, lastVisitDate) ||
                other.lastVisitDate == lastVisitDate) &&
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
    firstName,
    lastName,
    middleName,
    dateOfBirth,
    gender,
    photoUrl,
    medicalRecordNumber,
    status,
    priority,
    roomNumber,
    bedNumber,
    wardLocation,
    primaryPhysicianId,
    primaryPhysicianName,
    primaryNurseId,
    primaryNurseName,
    bloodType,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_medications),
    const DeepCollectionEquality().hash(_conditions),
    insuranceProvider,
    insurancePolicyNumber,
    emergencyContactName,
    emergencyContactPhone,
    notes,
    const DeepCollectionEquality().hash(_metadata),
    admissionDate,
    dischargeDate,
    lastVisitDate,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(this);
  }
}

abstract class _Patient extends Patient {
  const factory _Patient({
    required final String id,
    required final String firstName,
    required final String lastName,
    final String? middleName,
    required final DateTime dateOfBirth,
    required final String gender,
    final String? photoUrl,
    final String? medicalRecordNumber,
    final PatientStatus status,
    final PatientPriority priority,
    final String? roomNumber,
    final String? bedNumber,
    final String? wardLocation,
    final String? primaryPhysicianId,
    final String? primaryPhysicianName,
    final String? primaryNurseId,
    final String? primaryNurseName,
    final String? bloodType,
    final List<String> allergies,
    final List<String> medications,
    final List<String> conditions,
    final String? insuranceProvider,
    final String? insurancePolicyNumber,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
    final String? notes,
    final Map<String, dynamic>? metadata,
    final DateTime? admissionDate,
    final DateTime? dischargeDate,
    final DateTime? lastVisitDate,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$PatientImpl;
  const _Patient._() : super._();

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get middleName;
  @override
  DateTime get dateOfBirth;
  @override
  String get gender;
  @override
  String? get photoUrl;
  @override
  String? get medicalRecordNumber;
  @override
  PatientStatus get status;
  @override
  PatientPriority get priority;
  @override
  String? get roomNumber;
  @override
  String? get bedNumber;
  @override
  String? get wardLocation;
  @override
  String? get primaryPhysicianId;
  @override
  String? get primaryPhysicianName;
  @override
  String? get primaryNurseId;
  @override
  String? get primaryNurseName;
  @override
  String? get bloodType;
  @override
  List<String> get allergies;
  @override
  List<String> get medications;
  @override
  List<String> get conditions;
  @override
  String? get insuranceProvider;
  @override
  String? get insurancePolicyNumber;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get admissionDate;
  @override
  DateTime? get dischargeDate;
  @override
  DateTime? get lastVisitDate;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientVitals _$PatientVitalsFromJson(Map<String, dynamic> json) {
  return _PatientVitals.fromJson(json);
}

/// @nodoc
mixin _$PatientVitals {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  double? get temperature => throw _privateConstructorUsedError;
  String? get temperatureUnit =>
      throw _privateConstructorUsedError; // 'C' or 'F'
  int? get heartRate => throw _privateConstructorUsedError;
  int? get bloodPressureSystolic => throw _privateConstructorUsedError;
  int? get bloodPressureDiastolic => throw _privateConstructorUsedError;
  int? get respiratoryRate => throw _privateConstructorUsedError;
  double? get oxygenSaturation => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  String? get weightUnit => throw _privateConstructorUsedError; // 'kg' or 'lbs'
  double? get height => throw _privateConstructorUsedError;
  String? get heightUnit => throw _privateConstructorUsedError; // 'cm' or 'in'
  String? get painLevel => throw _privateConstructorUsedError; // 0-10 scale
  String? get recordedById => throw _privateConstructorUsedError;
  String? get recordedByName => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// Serializes this PatientVitals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientVitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientVitalsCopyWith<PatientVitals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientVitalsCopyWith<$Res> {
  factory $PatientVitalsCopyWith(
    PatientVitals value,
    $Res Function(PatientVitals) then,
  ) = _$PatientVitalsCopyWithImpl<$Res, PatientVitals>;
  @useResult
  $Res call({
    String id,
    String patientId,
    double? temperature,
    String? temperatureUnit,
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? respiratoryRate,
    double? oxygenSaturation,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    String? painLevel,
    String? recordedById,
    String? recordedByName,
    String? notes,
    DateTime recordedAt,
  });
}

/// @nodoc
class _$PatientVitalsCopyWithImpl<$Res, $Val extends PatientVitals>
    implements $PatientVitalsCopyWith<$Res> {
  _$PatientVitalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientVitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? temperature = freezed,
    Object? temperatureUnit = freezed,
    Object? heartRate = freezed,
    Object? bloodPressureSystolic = freezed,
    Object? bloodPressureDiastolic = freezed,
    Object? respiratoryRate = freezed,
    Object? oxygenSaturation = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? height = freezed,
    Object? heightUnit = freezed,
    Object? painLevel = freezed,
    Object? recordedById = freezed,
    Object? recordedByName = freezed,
    Object? notes = freezed,
    Object? recordedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: freezed == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double?,
            temperatureUnit: freezed == temperatureUnit
                ? _value.temperatureUnit
                : temperatureUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            heartRate: freezed == heartRate
                ? _value.heartRate
                : heartRate // ignore: cast_nullable_to_non_nullable
                      as int?,
            bloodPressureSystolic: freezed == bloodPressureSystolic
                ? _value.bloodPressureSystolic
                : bloodPressureSystolic // ignore: cast_nullable_to_non_nullable
                      as int?,
            bloodPressureDiastolic: freezed == bloodPressureDiastolic
                ? _value.bloodPressureDiastolic
                : bloodPressureDiastolic // ignore: cast_nullable_to_non_nullable
                      as int?,
            respiratoryRate: freezed == respiratoryRate
                ? _value.respiratoryRate
                : respiratoryRate // ignore: cast_nullable_to_non_nullable
                      as int?,
            oxygenSaturation: freezed == oxygenSaturation
                ? _value.oxygenSaturation
                : oxygenSaturation // ignore: cast_nullable_to_non_nullable
                      as double?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            weightUnit: freezed == weightUnit
                ? _value.weightUnit
                : weightUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double?,
            heightUnit: freezed == heightUnit
                ? _value.heightUnit
                : heightUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            painLevel: freezed == painLevel
                ? _value.painLevel
                : painLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordedById: freezed == recordedById
                ? _value.recordedById
                : recordedById // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordedByName: freezed == recordedByName
                ? _value.recordedByName
                : recordedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PatientVitalsImplCopyWith<$Res>
    implements $PatientVitalsCopyWith<$Res> {
  factory _$$PatientVitalsImplCopyWith(
    _$PatientVitalsImpl value,
    $Res Function(_$PatientVitalsImpl) then,
  ) = __$$PatientVitalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    double? temperature,
    String? temperatureUnit,
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? respiratoryRate,
    double? oxygenSaturation,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    String? painLevel,
    String? recordedById,
    String? recordedByName,
    String? notes,
    DateTime recordedAt,
  });
}

/// @nodoc
class __$$PatientVitalsImplCopyWithImpl<$Res>
    extends _$PatientVitalsCopyWithImpl<$Res, _$PatientVitalsImpl>
    implements _$$PatientVitalsImplCopyWith<$Res> {
  __$$PatientVitalsImplCopyWithImpl(
    _$PatientVitalsImpl _value,
    $Res Function(_$PatientVitalsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientVitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? temperature = freezed,
    Object? temperatureUnit = freezed,
    Object? heartRate = freezed,
    Object? bloodPressureSystolic = freezed,
    Object? bloodPressureDiastolic = freezed,
    Object? respiratoryRate = freezed,
    Object? oxygenSaturation = freezed,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? height = freezed,
    Object? heightUnit = freezed,
    Object? painLevel = freezed,
    Object? recordedById = freezed,
    Object? recordedByName = freezed,
    Object? notes = freezed,
    Object? recordedAt = null,
  }) {
    return _then(
      _$PatientVitalsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: freezed == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double?,
        temperatureUnit: freezed == temperatureUnit
            ? _value.temperatureUnit
            : temperatureUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        heartRate: freezed == heartRate
            ? _value.heartRate
            : heartRate // ignore: cast_nullable_to_non_nullable
                  as int?,
        bloodPressureSystolic: freezed == bloodPressureSystolic
            ? _value.bloodPressureSystolic
            : bloodPressureSystolic // ignore: cast_nullable_to_non_nullable
                  as int?,
        bloodPressureDiastolic: freezed == bloodPressureDiastolic
            ? _value.bloodPressureDiastolic
            : bloodPressureDiastolic // ignore: cast_nullable_to_non_nullable
                  as int?,
        respiratoryRate: freezed == respiratoryRate
            ? _value.respiratoryRate
            : respiratoryRate // ignore: cast_nullable_to_non_nullable
                  as int?,
        oxygenSaturation: freezed == oxygenSaturation
            ? _value.oxygenSaturation
            : oxygenSaturation // ignore: cast_nullable_to_non_nullable
                  as double?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        weightUnit: freezed == weightUnit
            ? _value.weightUnit
            : weightUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double?,
        heightUnit: freezed == heightUnit
            ? _value.heightUnit
            : heightUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        painLevel: freezed == painLevel
            ? _value.painLevel
            : painLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordedById: freezed == recordedById
            ? _value.recordedById
            : recordedById // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordedByName: freezed == recordedByName
            ? _value.recordedByName
            : recordedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientVitalsImpl extends _PatientVitals {
  const _$PatientVitalsImpl({
    required this.id,
    required this.patientId,
    this.temperature,
    this.temperatureUnit,
    this.heartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.painLevel,
    this.recordedById,
    this.recordedByName,
    this.notes,
    required this.recordedAt,
  }) : super._();

  factory _$PatientVitalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientVitalsImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final double? temperature;
  @override
  final String? temperatureUnit;
  // 'C' or 'F'
  @override
  final int? heartRate;
  @override
  final int? bloodPressureSystolic;
  @override
  final int? bloodPressureDiastolic;
  @override
  final int? respiratoryRate;
  @override
  final double? oxygenSaturation;
  @override
  final double? weight;
  @override
  final String? weightUnit;
  // 'kg' or 'lbs'
  @override
  final double? height;
  @override
  final String? heightUnit;
  // 'cm' or 'in'
  @override
  final String? painLevel;
  // 0-10 scale
  @override
  final String? recordedById;
  @override
  final String? recordedByName;
  @override
  final String? notes;
  @override
  final DateTime recordedAt;

  @override
  String toString() {
    return 'PatientVitals(id: $id, patientId: $patientId, temperature: $temperature, temperatureUnit: $temperatureUnit, heartRate: $heartRate, bloodPressureSystolic: $bloodPressureSystolic, bloodPressureDiastolic: $bloodPressureDiastolic, respiratoryRate: $respiratoryRate, oxygenSaturation: $oxygenSaturation, weight: $weight, weightUnit: $weightUnit, height: $height, heightUnit: $heightUnit, painLevel: $painLevel, recordedById: $recordedById, recordedByName: $recordedByName, notes: $notes, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientVitalsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.temperatureUnit, temperatureUnit) ||
                other.temperatureUnit == temperatureUnit) &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.bloodPressureSystolic, bloodPressureSystolic) ||
                other.bloodPressureSystolic == bloodPressureSystolic) &&
            (identical(other.bloodPressureDiastolic, bloodPressureDiastolic) ||
                other.bloodPressureDiastolic == bloodPressureDiastolic) &&
            (identical(other.respiratoryRate, respiratoryRate) ||
                other.respiratoryRate == respiratoryRate) &&
            (identical(other.oxygenSaturation, oxygenSaturation) ||
                other.oxygenSaturation == oxygenSaturation) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.heightUnit, heightUnit) ||
                other.heightUnit == heightUnit) &&
            (identical(other.painLevel, painLevel) ||
                other.painLevel == painLevel) &&
            (identical(other.recordedById, recordedById) ||
                other.recordedById == recordedById) &&
            (identical(other.recordedByName, recordedByName) ||
                other.recordedByName == recordedByName) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    temperature,
    temperatureUnit,
    heartRate,
    bloodPressureSystolic,
    bloodPressureDiastolic,
    respiratoryRate,
    oxygenSaturation,
    weight,
    weightUnit,
    height,
    heightUnit,
    painLevel,
    recordedById,
    recordedByName,
    notes,
    recordedAt,
  );

  /// Create a copy of PatientVitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientVitalsImplCopyWith<_$PatientVitalsImpl> get copyWith =>
      __$$PatientVitalsImplCopyWithImpl<_$PatientVitalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientVitalsImplToJson(this);
  }
}

abstract class _PatientVitals extends PatientVitals {
  const factory _PatientVitals({
    required final String id,
    required final String patientId,
    final double? temperature,
    final String? temperatureUnit,
    final int? heartRate,
    final int? bloodPressureSystolic,
    final int? bloodPressureDiastolic,
    final int? respiratoryRate,
    final double? oxygenSaturation,
    final double? weight,
    final String? weightUnit,
    final double? height,
    final String? heightUnit,
    final String? painLevel,
    final String? recordedById,
    final String? recordedByName,
    final String? notes,
    required final DateTime recordedAt,
  }) = _$PatientVitalsImpl;
  const _PatientVitals._() : super._();

  factory _PatientVitals.fromJson(Map<String, dynamic> json) =
      _$PatientVitalsImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  double? get temperature;
  @override
  String? get temperatureUnit; // 'C' or 'F'
  @override
  int? get heartRate;
  @override
  int? get bloodPressureSystolic;
  @override
  int? get bloodPressureDiastolic;
  @override
  int? get respiratoryRate;
  @override
  double? get oxygenSaturation;
  @override
  double? get weight;
  @override
  String? get weightUnit; // 'kg' or 'lbs'
  @override
  double? get height;
  @override
  String? get heightUnit; // 'cm' or 'in'
  @override
  String? get painLevel; // 0-10 scale
  @override
  String? get recordedById;
  @override
  String? get recordedByName;
  @override
  String? get notes;
  @override
  DateTime get recordedAt;

  /// Create a copy of PatientVitals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientVitalsImplCopyWith<_$PatientVitalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
