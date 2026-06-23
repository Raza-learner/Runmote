// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) {
  return _AgentInfo.fromJson(json);
}

/// @nodoc
mixin _$AgentInfo {
  String get name => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Serializes this AgentInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentInfoCopyWith<AgentInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentInfoCopyWith<$Res> {
  factory $AgentInfoCopyWith(AgentInfo value, $Res Function(AgentInfo) then) =
      _$AgentInfoCopyWithImpl<$Res, AgentInfo>;
  @useResult
  $Res call({String name, String version});
}

/// @nodoc
class _$AgentInfoCopyWithImpl<$Res, $Val extends AgentInfo>
    implements $AgentInfoCopyWith<$Res> {
  _$AgentInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? version = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgentInfoImplCopyWith<$Res>
    implements $AgentInfoCopyWith<$Res> {
  factory _$$AgentInfoImplCopyWith(
    _$AgentInfoImpl value,
    $Res Function(_$AgentInfoImpl) then,
  ) = __$$AgentInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String version});
}

/// @nodoc
class __$$AgentInfoImplCopyWithImpl<$Res>
    extends _$AgentInfoCopyWithImpl<$Res, _$AgentInfoImpl>
    implements _$$AgentInfoImplCopyWith<$Res> {
  __$$AgentInfoImplCopyWithImpl(
    _$AgentInfoImpl _value,
    $Res Function(_$AgentInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgentInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? version = null}) {
    return _then(
      _$AgentInfoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentInfoImpl implements _AgentInfo {
  const _$AgentInfoImpl({required this.name, required this.version});

  factory _$AgentInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentInfoImplFromJson(json);

  @override
  final String name;
  @override
  final String version;

  @override
  String toString() {
    return 'AgentInfo(name: $name, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, version);

  /// Create a copy of AgentInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentInfoImplCopyWith<_$AgentInfoImpl> get copyWith =>
      __$$AgentInfoImplCopyWithImpl<_$AgentInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentInfoImplToJson(this);
  }
}

abstract class _AgentInfo implements AgentInfo {
  const factory _AgentInfo({
    required final String name,
    required final String version,
  }) = _$AgentInfoImpl;

  factory _AgentInfo.fromJson(Map<String, dynamic> json) =
      _$AgentInfoImpl.fromJson;

  @override
  String get name;
  @override
  String get version;

  /// Create a copy of AgentInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentInfoImplCopyWith<_$AgentInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
