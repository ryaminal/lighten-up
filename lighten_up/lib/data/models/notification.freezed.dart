// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Notification _$NotificationFromJson(Map<String, dynamic> json) {
  return _Notification.fromJson(json);
}

/// @nodoc
mixin _$Notification {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;
  String? get actionType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get actionData => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Notification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Notification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationCopyWith<Notification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationCopyWith<$Res> {
  factory $NotificationCopyWith(
    Notification value,
    $Res Function(Notification) then,
  ) = _$NotificationCopyWithImpl<$Res, Notification>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String body,
    NotificationType type,
    NotificationPriority priority,
    bool isRead,
    String? actionUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? imageUrl,
    String? iconUrl,
    DateTime? readAt,
    DateTime? expiresAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$NotificationCopyWithImpl<$Res, $Val extends Notification>
    implements $NotificationCopyWith<$Res> {
  _$NotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Notification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? priority = null,
    Object? isRead = null,
    Object? actionUrl = freezed,
    Object? actionType = freezed,
    Object? actionData = freezed,
    Object? imageUrl = freezed,
    Object? iconUrl = freezed,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            actionUrl: freezed == actionUrl
                ? _value.actionUrl
                : actionUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionType: freezed == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionData: freezed == actionData
                ? _value.actionData
                : actionData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            iconUrl: freezed == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$NotificationImplCopyWith<$Res>
    implements $NotificationCopyWith<$Res> {
  factory _$$NotificationImplCopyWith(
    _$NotificationImpl value,
    $Res Function(_$NotificationImpl) then,
  ) = __$$NotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String body,
    NotificationType type,
    NotificationPriority priority,
    bool isRead,
    String? actionUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? imageUrl,
    String? iconUrl,
    DateTime? readAt,
    DateTime? expiresAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$NotificationImplCopyWithImpl<$Res>
    extends _$NotificationCopyWithImpl<$Res, _$NotificationImpl>
    implements _$$NotificationImplCopyWith<$Res> {
  __$$NotificationImplCopyWithImpl(
    _$NotificationImpl _value,
    $Res Function(_$NotificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Notification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? priority = null,
    Object? isRead = null,
    Object? actionUrl = freezed,
    Object? actionType = freezed,
    Object? actionData = freezed,
    Object? imageUrl = freezed,
    Object? iconUrl = freezed,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$NotificationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        actionUrl: freezed == actionUrl
            ? _value.actionUrl
            : actionUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionType: freezed == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionData: freezed == actionData
            ? _value._actionData
            : actionData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        iconUrl: freezed == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$NotificationImpl extends _Notification {
  const _$NotificationImpl({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = NotificationType.system,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.actionUrl,
    this.actionType,
    final Map<String, dynamic>? actionData,
    this.imageUrl,
    this.iconUrl,
    this.readAt,
    this.expiresAt,
    required this.createdAt,
  }) : _actionData = actionData,
       super._();

  factory _$NotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String body;
  @override
  @JsonKey()
  final NotificationType type;
  @override
  @JsonKey()
  final NotificationPriority priority;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? actionUrl;
  @override
  final String? actionType;
  final Map<String, dynamic>? _actionData;
  @override
  Map<String, dynamic>? get actionData {
    final value = _actionData;
    if (value == null) return null;
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? iconUrl;
  @override
  final DateTime? readAt;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, title: $title, body: $body, type: $type, priority: $priority, isRead: $isRead, actionUrl: $actionUrl, actionType: $actionType, actionData: $actionData, imageUrl: $imageUrl, iconUrl: $iconUrl, readAt: $readAt, expiresAt: $expiresAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            const DeepCollectionEquality().equals(
              other._actionData,
              _actionData,
            ) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    body,
    type,
    priority,
    isRead,
    actionUrl,
    actionType,
    const DeepCollectionEquality().hash(_actionData),
    imageUrl,
    iconUrl,
    readAt,
    expiresAt,
    createdAt,
  );

  /// Create a copy of Notification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationImplCopyWith<_$NotificationImpl> get copyWith =>
      __$$NotificationImplCopyWithImpl<_$NotificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationImplToJson(this);
  }
}

abstract class _Notification extends Notification {
  const factory _Notification({
    required final String id,
    required final String userId,
    required final String title,
    required final String body,
    final NotificationType type,
    final NotificationPriority priority,
    final bool isRead,
    final String? actionUrl,
    final String? actionType,
    final Map<String, dynamic>? actionData,
    final String? imageUrl,
    final String? iconUrl,
    final DateTime? readAt,
    final DateTime? expiresAt,
    required final DateTime createdAt,
  }) = _$NotificationImpl;
  const _Notification._() : super._();

  factory _Notification.fromJson(Map<String, dynamic> json) =
      _$NotificationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get body;
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  bool get isRead;
  @override
  String? get actionUrl;
  @override
  String? get actionType;
  @override
  Map<String, dynamic>? get actionData;
  @override
  String? get imageUrl;
  @override
  String? get iconUrl;
  @override
  DateTime? get readAt;
  @override
  DateTime? get expiresAt;
  @override
  DateTime get createdAt;

  /// Create a copy of Notification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationImplCopyWith<_$NotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  String get userId => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get vibrationEnabled => throw _privateConstructorUsedError;
  bool get messageNotifications => throw _privateConstructorUsedError;
  bool get alertNotifications => throw _privateConstructorUsedError;
  bool get appointmentNotifications => throw _privateConstructorUsedError;
  bool get systemNotifications => throw _privateConstructorUsedError;
  bool get reminderNotifications => throw _privateConstructorUsedError;
  String? get quietHoursStart => throw _privateConstructorUsedError;
  String? get quietHoursEnd => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(
    NotificationSettings value,
    $Res Function(NotificationSettings) then,
  ) = _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call({
    String userId,
    bool enabled,
    bool soundEnabled,
    bool vibrationEnabled,
    bool messageNotifications,
    bool alertNotifications,
    bool appointmentNotifications,
    bool systemNotifications,
    bool reminderNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<
  $Res,
  $Val extends NotificationSettings
>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? enabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? messageNotifications = null,
    Object? alertNotifications = null,
    Object? appointmentNotifications = null,
    Object? systemNotifications = null,
    Object? reminderNotifications = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
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
            messageNotifications: null == messageNotifications
                ? _value.messageNotifications
                : messageNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            alertNotifications: null == alertNotifications
                ? _value.alertNotifications
                : alertNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            appointmentNotifications: null == appointmentNotifications
                ? _value.appointmentNotifications
                : appointmentNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            systemNotifications: null == systemNotifications
                ? _value.systemNotifications
                : systemNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderNotifications: null == reminderNotifications
                ? _value.reminderNotifications
                : reminderNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursStart: freezed == quietHoursStart
                ? _value.quietHoursStart
                : quietHoursStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            quietHoursEnd: freezed == quietHoursEnd
                ? _value.quietHoursEnd
                : quietHoursEnd // ignore: cast_nullable_to_non_nullable
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
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(
    _$NotificationSettingsImpl value,
    $Res Function(_$NotificationSettingsImpl) then,
  ) = __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    bool enabled,
    bool soundEnabled,
    bool vibrationEnabled,
    bool messageNotifications,
    bool alertNotifications,
    bool appointmentNotifications,
    bool systemNotifications,
    bool reminderNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(
    _$NotificationSettingsImpl _value,
    $Res Function(_$NotificationSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? enabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? messageNotifications = null,
    Object? alertNotifications = null,
    Object? appointmentNotifications = null,
    Object? systemNotifications = null,
    Object? reminderNotifications = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$NotificationSettingsImpl(
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
        messageNotifications: null == messageNotifications
            ? _value.messageNotifications
            : messageNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        alertNotifications: null == alertNotifications
            ? _value.alertNotifications
            : alertNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        appointmentNotifications: null == appointmentNotifications
            ? _value.appointmentNotifications
            : appointmentNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        systemNotifications: null == systemNotifications
            ? _value.systemNotifications
            : systemNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderNotifications: null == reminderNotifications
            ? _value.reminderNotifications
            : reminderNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursStart: freezed == quietHoursStart
            ? _value.quietHoursStart
            : quietHoursStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        quietHoursEnd: freezed == quietHoursEnd
            ? _value.quietHoursEnd
            : quietHoursEnd // ignore: cast_nullable_to_non_nullable
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
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl({
    required this.userId,
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.messageNotifications = true,
    this.alertNotifications = true,
    this.appointmentNotifications = true,
    this.systemNotifications = true,
    this.reminderNotifications = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.updatedAt,
  });

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

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
  final bool messageNotifications;
  @override
  @JsonKey()
  final bool alertNotifications;
  @override
  @JsonKey()
  final bool appointmentNotifications;
  @override
  @JsonKey()
  final bool systemNotifications;
  @override
  @JsonKey()
  final bool reminderNotifications;
  @override
  final String? quietHoursStart;
  @override
  final String? quietHoursEnd;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationSettings(userId: $userId, enabled: $enabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, messageNotifications: $messageNotifications, alertNotifications: $alertNotifications, appointmentNotifications: $appointmentNotifications, systemNotifications: $systemNotifications, reminderNotifications: $reminderNotifications, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.messageNotifications, messageNotifications) ||
                other.messageNotifications == messageNotifications) &&
            (identical(other.alertNotifications, alertNotifications) ||
                other.alertNotifications == alertNotifications) &&
            (identical(
                  other.appointmentNotifications,
                  appointmentNotifications,
                ) ||
                other.appointmentNotifications == appointmentNotifications) &&
            (identical(other.systemNotifications, systemNotifications) ||
                other.systemNotifications == systemNotifications) &&
            (identical(other.reminderNotifications, reminderNotifications) ||
                other.reminderNotifications == reminderNotifications) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
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
    messageNotifications,
    alertNotifications,
    appointmentNotifications,
    systemNotifications,
    reminderNotifications,
    quietHoursStart,
    quietHoursEnd,
    updatedAt,
  );

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith =>
      __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(this);
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings({
    required final String userId,
    final bool enabled,
    final bool soundEnabled,
    final bool vibrationEnabled,
    final bool messageNotifications,
    final bool alertNotifications,
    final bool appointmentNotifications,
    final bool systemNotifications,
    final bool reminderNotifications,
    final String? quietHoursStart,
    final String? quietHoursEnd,
    final DateTime? updatedAt,
  }) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  String get userId;
  @override
  bool get enabled;
  @override
  bool get soundEnabled;
  @override
  bool get vibrationEnabled;
  @override
  bool get messageNotifications;
  @override
  bool get alertNotifications;
  @override
  bool get appointmentNotifications;
  @override
  bool get systemNotifications;
  @override
  bool get reminderNotifications;
  @override
  String? get quietHoursStart;
  @override
  String? get quietHoursEnd;
  @override
  DateTime? get updatedAt;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
