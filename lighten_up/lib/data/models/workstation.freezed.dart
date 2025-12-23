// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workstation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Workstation _$WorkstationFromJson(Map<String, dynamic> json) {
  return _Workstation.fromJson(json);
}

/// @nodoc
mixin _$Workstation {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get zone => throw _privateConstructorUsedError;
  WorkstationStatus get status => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this Workstation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workstation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkstationCopyWith<Workstation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkstationCopyWith<$Res> {
  factory $WorkstationCopyWith(
    Workstation value,
    $Res Function(Workstation) then,
  ) = _$WorkstationCopyWithImpl<$Res, Workstation>;
  @useResult
  $Res call({
    String id,
    String name,
    String zone,
    WorkstationStatus status,
    String? description,
  });
}

/// @nodoc
class _$WorkstationCopyWithImpl<$Res, $Val extends Workstation>
    implements $WorkstationCopyWith<$Res> {
  _$WorkstationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workstation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? zone = null,
    Object? status = null,
    Object? description = freezed,
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
            zone: null == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WorkstationStatus,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkstationImplCopyWith<$Res>
    implements $WorkstationCopyWith<$Res> {
  factory _$$WorkstationImplCopyWith(
    _$WorkstationImpl value,
    $Res Function(_$WorkstationImpl) then,
  ) = __$$WorkstationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String zone,
    WorkstationStatus status,
    String? description,
  });
}

/// @nodoc
class __$$WorkstationImplCopyWithImpl<$Res>
    extends _$WorkstationCopyWithImpl<$Res, _$WorkstationImpl>
    implements _$$WorkstationImplCopyWith<$Res> {
  __$$WorkstationImplCopyWithImpl(
    _$WorkstationImpl _value,
    $Res Function(_$WorkstationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Workstation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? zone = null,
    Object? status = null,
    Object? description = freezed,
  }) {
    return _then(
      _$WorkstationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        zone: null == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WorkstationStatus,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkstationImpl implements _Workstation {
  const _$WorkstationImpl({
    required this.id,
    required this.name,
    required this.zone,
    required this.status,
    this.description,
  });

  factory _$WorkstationImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkstationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String zone;
  @override
  final WorkstationStatus status;
  @override
  final String? description;

  @override
  String toString() {
    return 'Workstation(id: $id, name: $name, zone: $zone, status: $status, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkstationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, zone, status, description);

  /// Create a copy of Workstation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkstationImplCopyWith<_$WorkstationImpl> get copyWith =>
      __$$WorkstationImplCopyWithImpl<_$WorkstationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkstationImplToJson(this);
  }
}

abstract class _Workstation implements Workstation {
  const factory _Workstation({
    required final String id,
    required final String name,
    required final String zone,
    required final WorkstationStatus status,
    final String? description,
  }) = _$WorkstationImpl;

  factory _Workstation.fromJson(Map<String, dynamic> json) =
      _$WorkstationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get zone;
  @override
  WorkstationStatus get status;
  @override
  String? get description;

  /// Create a copy of Workstation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkstationImplCopyWith<_$WorkstationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
