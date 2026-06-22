// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gateway_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GatewaySource _$GatewaySourceFromJson(Map<String, dynamic> json) {
  return _GatewaySource.fromJson(json);
}

/// @nodoc
mixin _$GatewaySource {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get scheme => throw _privateConstructorUsedError;
  String get host => throw _privateConstructorUsedError;
  String get gatewayCredential => throw _privateConstructorUsedError;
  DateTime? get gatewayCredentialExpiresAt =>
      throw _privateConstructorUsedError;
  String? get gatewayRemoteMode => throw _privateConstructorUsedError;

  /// Serializes this GatewaySource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GatewaySource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GatewaySourceCopyWith<GatewaySource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GatewaySourceCopyWith<$Res> {
  factory $GatewaySourceCopyWith(
    GatewaySource value,
    $Res Function(GatewaySource) then,
  ) = _$GatewaySourceCopyWithImpl<$Res, GatewaySource>;
  @useResult
  $Res call({
    String id,
    String name,
    String scheme,
    String host,
    String gatewayCredential,
    DateTime? gatewayCredentialExpiresAt,
    String? gatewayRemoteMode,
  });
}

/// @nodoc
class _$GatewaySourceCopyWithImpl<$Res, $Val extends GatewaySource>
    implements $GatewaySourceCopyWith<$Res> {
  _$GatewaySourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GatewaySource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scheme = null,
    Object? host = null,
    Object? gatewayCredential = null,
    Object? gatewayCredentialExpiresAt = freezed,
    Object? gatewayRemoteMode = freezed,
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
            scheme: null == scheme
                ? _value.scheme
                : scheme // ignore: cast_nullable_to_non_nullable
                      as String,
            host: null == host
                ? _value.host
                : host // ignore: cast_nullable_to_non_nullable
                      as String,
            gatewayCredential: null == gatewayCredential
                ? _value.gatewayCredential
                : gatewayCredential // ignore: cast_nullable_to_non_nullable
                      as String,
            gatewayCredentialExpiresAt: freezed == gatewayCredentialExpiresAt
                ? _value.gatewayCredentialExpiresAt
                : gatewayCredentialExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            gatewayRemoteMode: freezed == gatewayRemoteMode
                ? _value.gatewayRemoteMode
                : gatewayRemoteMode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GatewaySourceImplCopyWith<$Res>
    implements $GatewaySourceCopyWith<$Res> {
  factory _$$GatewaySourceImplCopyWith(
    _$GatewaySourceImpl value,
    $Res Function(_$GatewaySourceImpl) then,
  ) = __$$GatewaySourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String scheme,
    String host,
    String gatewayCredential,
    DateTime? gatewayCredentialExpiresAt,
    String? gatewayRemoteMode,
  });
}

/// @nodoc
class __$$GatewaySourceImplCopyWithImpl<$Res>
    extends _$GatewaySourceCopyWithImpl<$Res, _$GatewaySourceImpl>
    implements _$$GatewaySourceImplCopyWith<$Res> {
  __$$GatewaySourceImplCopyWithImpl(
    _$GatewaySourceImpl _value,
    $Res Function(_$GatewaySourceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GatewaySource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scheme = null,
    Object? host = null,
    Object? gatewayCredential = null,
    Object? gatewayCredentialExpiresAt = freezed,
    Object? gatewayRemoteMode = freezed,
  }) {
    return _then(
      _$GatewaySourceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        scheme: null == scheme
            ? _value.scheme
            : scheme // ignore: cast_nullable_to_non_nullable
                  as String,
        host: null == host
            ? _value.host
            : host // ignore: cast_nullable_to_non_nullable
                  as String,
        gatewayCredential: null == gatewayCredential
            ? _value.gatewayCredential
            : gatewayCredential // ignore: cast_nullable_to_non_nullable
                  as String,
        gatewayCredentialExpiresAt: freezed == gatewayCredentialExpiresAt
            ? _value.gatewayCredentialExpiresAt
            : gatewayCredentialExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        gatewayRemoteMode: freezed == gatewayRemoteMode
            ? _value.gatewayRemoteMode
            : gatewayRemoteMode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GatewaySourceImpl implements _GatewaySource {
  const _$GatewaySourceImpl({
    required this.id,
    required this.name,
    this.scheme = 'http',
    required this.host,
    required this.gatewayCredential,
    this.gatewayCredentialExpiresAt,
    this.gatewayRemoteMode,
  });

  factory _$GatewaySourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GatewaySourceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String scheme;
  @override
  final String host;
  @override
  final String gatewayCredential;
  @override
  final DateTime? gatewayCredentialExpiresAt;
  @override
  final String? gatewayRemoteMode;

  @override
  String toString() {
    return 'GatewaySource(id: $id, name: $name, scheme: $scheme, host: $host, gatewayCredential: $gatewayCredential, gatewayCredentialExpiresAt: $gatewayCredentialExpiresAt, gatewayRemoteMode: $gatewayRemoteMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GatewaySourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.scheme, scheme) || other.scheme == scheme) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.gatewayCredential, gatewayCredential) ||
                other.gatewayCredential == gatewayCredential) &&
            (identical(
                  other.gatewayCredentialExpiresAt,
                  gatewayCredentialExpiresAt,
                ) ||
                other.gatewayCredentialExpiresAt ==
                    gatewayCredentialExpiresAt) &&
            (identical(other.gatewayRemoteMode, gatewayRemoteMode) ||
                other.gatewayRemoteMode == gatewayRemoteMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    scheme,
    host,
    gatewayCredential,
    gatewayCredentialExpiresAt,
    gatewayRemoteMode,
  );

  /// Create a copy of GatewaySource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GatewaySourceImplCopyWith<_$GatewaySourceImpl> get copyWith =>
      __$$GatewaySourceImplCopyWithImpl<_$GatewaySourceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GatewaySourceImplToJson(this);
  }
}

abstract class _GatewaySource implements GatewaySource {
  const factory _GatewaySource({
    required final String id,
    required final String name,
    final String scheme,
    required final String host,
    required final String gatewayCredential,
    final DateTime? gatewayCredentialExpiresAt,
    final String? gatewayRemoteMode,
  }) = _$GatewaySourceImpl;

  factory _GatewaySource.fromJson(Map<String, dynamic> json) =
      _$GatewaySourceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get scheme;
  @override
  String get host;
  @override
  String get gatewayCredential;
  @override
  DateTime? get gatewayCredentialExpiresAt;
  @override
  String? get gatewayRemoteMode;

  /// Create a copy of GatewaySource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GatewaySourceImplCopyWith<_$GatewaySourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
