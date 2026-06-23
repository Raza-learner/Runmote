// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgentCapabilities _$AgentCapabilitiesFromJson(Map<String, dynamic> json) {
  return _AgentCapabilities.fromJson(json);
}

/// @nodoc
mixin _$AgentCapabilities {
  bool get canSendImages => throw _privateConstructorUsedError;
  bool get supportsEmbeddedContext => throw _privateConstructorUsedError;
  bool get supportsSessionList => throw _privateConstructorUsedError;
  bool get supportsLoadSession => throw _privateConstructorUsedError;
  bool get supportsDelete => throw _privateConstructorUsedError;

  /// Serializes this AgentCapabilities to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentCapabilitiesCopyWith<AgentCapabilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentCapabilitiesCopyWith<$Res> {
  factory $AgentCapabilitiesCopyWith(
    AgentCapabilities value,
    $Res Function(AgentCapabilities) then,
  ) = _$AgentCapabilitiesCopyWithImpl<$Res, AgentCapabilities>;
  @useResult
  $Res call({
    bool canSendImages,
    bool supportsEmbeddedContext,
    bool supportsSessionList,
    bool supportsLoadSession,
    bool supportsDelete,
  });
}

/// @nodoc
class _$AgentCapabilitiesCopyWithImpl<$Res, $Val extends AgentCapabilities>
    implements $AgentCapabilitiesCopyWith<$Res> {
  _$AgentCapabilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canSendImages = null,
    Object? supportsEmbeddedContext = null,
    Object? supportsSessionList = null,
    Object? supportsLoadSession = null,
    Object? supportsDelete = null,
  }) {
    return _then(
      _value.copyWith(
            canSendImages: null == canSendImages
                ? _value.canSendImages
                : canSendImages // ignore: cast_nullable_to_non_nullable
                      as bool,
            supportsEmbeddedContext: null == supportsEmbeddedContext
                ? _value.supportsEmbeddedContext
                : supportsEmbeddedContext // ignore: cast_nullable_to_non_nullable
                      as bool,
            supportsSessionList: null == supportsSessionList
                ? _value.supportsSessionList
                : supportsSessionList // ignore: cast_nullable_to_non_nullable
                      as bool,
            supportsLoadSession: null == supportsLoadSession
                ? _value.supportsLoadSession
                : supportsLoadSession // ignore: cast_nullable_to_non_nullable
                      as bool,
            supportsDelete: null == supportsDelete
                ? _value.supportsDelete
                : supportsDelete // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgentCapabilitiesImplCopyWith<$Res>
    implements $AgentCapabilitiesCopyWith<$Res> {
  factory _$$AgentCapabilitiesImplCopyWith(
    _$AgentCapabilitiesImpl value,
    $Res Function(_$AgentCapabilitiesImpl) then,
  ) = __$$AgentCapabilitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool canSendImages,
    bool supportsEmbeddedContext,
    bool supportsSessionList,
    bool supportsLoadSession,
    bool supportsDelete,
  });
}

/// @nodoc
class __$$AgentCapabilitiesImplCopyWithImpl<$Res>
    extends _$AgentCapabilitiesCopyWithImpl<$Res, _$AgentCapabilitiesImpl>
    implements _$$AgentCapabilitiesImplCopyWith<$Res> {
  __$$AgentCapabilitiesImplCopyWithImpl(
    _$AgentCapabilitiesImpl _value,
    $Res Function(_$AgentCapabilitiesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgentCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canSendImages = null,
    Object? supportsEmbeddedContext = null,
    Object? supportsSessionList = null,
    Object? supportsLoadSession = null,
    Object? supportsDelete = null,
  }) {
    return _then(
      _$AgentCapabilitiesImpl(
        canSendImages: null == canSendImages
            ? _value.canSendImages
            : canSendImages // ignore: cast_nullable_to_non_nullable
                  as bool,
        supportsEmbeddedContext: null == supportsEmbeddedContext
            ? _value.supportsEmbeddedContext
            : supportsEmbeddedContext // ignore: cast_nullable_to_non_nullable
                  as bool,
        supportsSessionList: null == supportsSessionList
            ? _value.supportsSessionList
            : supportsSessionList // ignore: cast_nullable_to_non_nullable
                  as bool,
        supportsLoadSession: null == supportsLoadSession
            ? _value.supportsLoadSession
            : supportsLoadSession // ignore: cast_nullable_to_non_nullable
                  as bool,
        supportsDelete: null == supportsDelete
            ? _value.supportsDelete
            : supportsDelete // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentCapabilitiesImpl implements _AgentCapabilities {
  const _$AgentCapabilitiesImpl({
    this.canSendImages = false,
    this.supportsEmbeddedContext = false,
    this.supportsSessionList = false,
    this.supportsLoadSession = false,
    this.supportsDelete = false,
  });

  factory _$AgentCapabilitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentCapabilitiesImplFromJson(json);

  @override
  @JsonKey()
  final bool canSendImages;
  @override
  @JsonKey()
  final bool supportsEmbeddedContext;
  @override
  @JsonKey()
  final bool supportsSessionList;
  @override
  @JsonKey()
  final bool supportsLoadSession;
  @override
  @JsonKey()
  final bool supportsDelete;

  @override
  String toString() {
    return 'AgentCapabilities(canSendImages: $canSendImages, supportsEmbeddedContext: $supportsEmbeddedContext, supportsSessionList: $supportsSessionList, supportsLoadSession: $supportsLoadSession, supportsDelete: $supportsDelete)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentCapabilitiesImpl &&
            (identical(other.canSendImages, canSendImages) ||
                other.canSendImages == canSendImages) &&
            (identical(
                  other.supportsEmbeddedContext,
                  supportsEmbeddedContext,
                ) ||
                other.supportsEmbeddedContext == supportsEmbeddedContext) &&
            (identical(other.supportsSessionList, supportsSessionList) ||
                other.supportsSessionList == supportsSessionList) &&
            (identical(other.supportsLoadSession, supportsLoadSession) ||
                other.supportsLoadSession == supportsLoadSession) &&
            (identical(other.supportsDelete, supportsDelete) ||
                other.supportsDelete == supportsDelete));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    canSendImages,
    supportsEmbeddedContext,
    supportsSessionList,
    supportsLoadSession,
    supportsDelete,
  );

  /// Create a copy of AgentCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentCapabilitiesImplCopyWith<_$AgentCapabilitiesImpl> get copyWith =>
      __$$AgentCapabilitiesImplCopyWithImpl<_$AgentCapabilitiesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentCapabilitiesImplToJson(this);
  }
}

abstract class _AgentCapabilities implements AgentCapabilities {
  const factory _AgentCapabilities({
    final bool canSendImages,
    final bool supportsEmbeddedContext,
    final bool supportsSessionList,
    final bool supportsLoadSession,
    final bool supportsDelete,
  }) = _$AgentCapabilitiesImpl;

  factory _AgentCapabilities.fromJson(Map<String, dynamic> json) =
      _$AgentCapabilitiesImpl.fromJson;

  @override
  bool get canSendImages;
  @override
  bool get supportsEmbeddedContext;
  @override
  bool get supportsSessionList;
  @override
  bool get supportsLoadSession;
  @override
  bool get supportsDelete;

  /// Create a copy of AgentCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentCapabilitiesImplCopyWith<_$AgentCapabilitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
