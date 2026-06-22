// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gateway_agent_binding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GatewayAgentBinding {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get gatewaySourceId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String? get preferredAuthMethodId => throw _privateConstructorUsedError;

  /// Create a copy of GatewayAgentBinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GatewayAgentBindingCopyWith<GatewayAgentBinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GatewayAgentBindingCopyWith<$Res> {
  factory $GatewayAgentBindingCopyWith(
    GatewayAgentBinding value,
    $Res Function(GatewayAgentBinding) then,
  ) = _$GatewayAgentBindingCopyWithImpl<$Res, GatewayAgentBinding>;
  @useResult
  $Res call({
    String id,
    String name,
    String gatewaySourceId,
    String agentId,
    String? preferredAuthMethodId,
  });
}

/// @nodoc
class _$GatewayAgentBindingCopyWithImpl<$Res, $Val extends GatewayAgentBinding>
    implements $GatewayAgentBindingCopyWith<$Res> {
  _$GatewayAgentBindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GatewayAgentBinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gatewaySourceId = null,
    Object? agentId = null,
    Object? preferredAuthMethodId = freezed,
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
            gatewaySourceId: null == gatewaySourceId
                ? _value.gatewaySourceId
                : gatewaySourceId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredAuthMethodId: freezed == preferredAuthMethodId
                ? _value.preferredAuthMethodId
                : preferredAuthMethodId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GatewayAgentBindingImplCopyWith<$Res>
    implements $GatewayAgentBindingCopyWith<$Res> {
  factory _$$GatewayAgentBindingImplCopyWith(
    _$GatewayAgentBindingImpl value,
    $Res Function(_$GatewayAgentBindingImpl) then,
  ) = __$$GatewayAgentBindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String gatewaySourceId,
    String agentId,
    String? preferredAuthMethodId,
  });
}

/// @nodoc
class __$$GatewayAgentBindingImplCopyWithImpl<$Res>
    extends _$GatewayAgentBindingCopyWithImpl<$Res, _$GatewayAgentBindingImpl>
    implements _$$GatewayAgentBindingImplCopyWith<$Res> {
  __$$GatewayAgentBindingImplCopyWithImpl(
    _$GatewayAgentBindingImpl _value,
    $Res Function(_$GatewayAgentBindingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GatewayAgentBinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gatewaySourceId = null,
    Object? agentId = null,
    Object? preferredAuthMethodId = freezed,
  }) {
    return _then(
      _$GatewayAgentBindingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        gatewaySourceId: null == gatewaySourceId
            ? _value.gatewaySourceId
            : gatewaySourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredAuthMethodId: freezed == preferredAuthMethodId
            ? _value.preferredAuthMethodId
            : preferredAuthMethodId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$GatewayAgentBindingImpl implements _GatewayAgentBinding {
  const _$GatewayAgentBindingImpl({
    required this.id,
    required this.name,
    required this.gatewaySourceId,
    required this.agentId,
    this.preferredAuthMethodId,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String gatewaySourceId;
  @override
  final String agentId;
  @override
  final String? preferredAuthMethodId;

  @override
  String toString() {
    return 'GatewayAgentBinding(id: $id, name: $name, gatewaySourceId: $gatewaySourceId, agentId: $agentId, preferredAuthMethodId: $preferredAuthMethodId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GatewayAgentBindingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gatewaySourceId, gatewaySourceId) ||
                other.gatewaySourceId == gatewaySourceId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.preferredAuthMethodId, preferredAuthMethodId) ||
                other.preferredAuthMethodId == preferredAuthMethodId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    gatewaySourceId,
    agentId,
    preferredAuthMethodId,
  );

  /// Create a copy of GatewayAgentBinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GatewayAgentBindingImplCopyWith<_$GatewayAgentBindingImpl> get copyWith =>
      __$$GatewayAgentBindingImplCopyWithImpl<_$GatewayAgentBindingImpl>(
        this,
        _$identity,
      );
}

abstract class _GatewayAgentBinding implements GatewayAgentBinding {
  const factory _GatewayAgentBinding({
    required final String id,
    required final String name,
    required final String gatewaySourceId,
    required final String agentId,
    final String? preferredAuthMethodId,
  }) = _$GatewayAgentBindingImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get gatewaySourceId;
  @override
  String get agentId;
  @override
  String? get preferredAuthMethodId;

  /// Create a copy of GatewayAgentBinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GatewayAgentBindingImplCopyWith<_$GatewayAgentBindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LaunchableTarget {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ServerConfig server) manual,
    required TResult Function(
      GatewayAgentBinding binding,
      GatewaySource gatewaySource,
    )
    gatewayAgent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ServerConfig server)? manual,
    TResult? Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ServerConfig server)? manual,
    TResult Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Manual value) manual,
    required TResult Function(GatewayAgent value) gatewayAgent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Manual value)? manual,
    TResult? Function(GatewayAgent value)? gatewayAgent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Manual value)? manual,
    TResult Function(GatewayAgent value)? gatewayAgent,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaunchableTargetCopyWith<$Res> {
  factory $LaunchableTargetCopyWith(
    LaunchableTarget value,
    $Res Function(LaunchableTarget) then,
  ) = _$LaunchableTargetCopyWithImpl<$Res, LaunchableTarget>;
}

/// @nodoc
class _$LaunchableTargetCopyWithImpl<$Res, $Val extends LaunchableTarget>
    implements $LaunchableTargetCopyWith<$Res> {
  _$LaunchableTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ManualImplCopyWith<$Res> {
  factory _$$ManualImplCopyWith(
    _$ManualImpl value,
    $Res Function(_$ManualImpl) then,
  ) = __$$ManualImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ServerConfig server});

  $ServerConfigCopyWith<$Res> get server;
}

/// @nodoc
class __$$ManualImplCopyWithImpl<$Res>
    extends _$LaunchableTargetCopyWithImpl<$Res, _$ManualImpl>
    implements _$$ManualImplCopyWith<$Res> {
  __$$ManualImplCopyWithImpl(
    _$ManualImpl _value,
    $Res Function(_$ManualImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? server = null}) {
    return _then(
      _$ManualImpl(
        null == server
            ? _value.server
            : server // ignore: cast_nullable_to_non_nullable
                  as ServerConfig,
      ),
    );
  }

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServerConfigCopyWith<$Res> get server {
    return $ServerConfigCopyWith<$Res>(_value.server, (value) {
      return _then(_value.copyWith(server: value));
    });
  }
}

/// @nodoc

class _$ManualImpl implements Manual {
  const _$ManualImpl(this.server);

  @override
  final ServerConfig server;

  @override
  String toString() {
    return 'LaunchableTarget.manual(server: $server)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManualImpl &&
            (identical(other.server, server) || other.server == server));
  }

  @override
  int get hashCode => Object.hash(runtimeType, server);

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManualImplCopyWith<_$ManualImpl> get copyWith =>
      __$$ManualImplCopyWithImpl<_$ManualImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ServerConfig server) manual,
    required TResult Function(
      GatewayAgentBinding binding,
      GatewaySource gatewaySource,
    )
    gatewayAgent,
  }) {
    return manual(server);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ServerConfig server)? manual,
    TResult? Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
  }) {
    return manual?.call(server);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ServerConfig server)? manual,
    TResult Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
    required TResult orElse(),
  }) {
    if (manual != null) {
      return manual(server);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Manual value) manual,
    required TResult Function(GatewayAgent value) gatewayAgent,
  }) {
    return manual(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Manual value)? manual,
    TResult? Function(GatewayAgent value)? gatewayAgent,
  }) {
    return manual?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Manual value)? manual,
    TResult Function(GatewayAgent value)? gatewayAgent,
    required TResult orElse(),
  }) {
    if (manual != null) {
      return manual(this);
    }
    return orElse();
  }
}

abstract class Manual implements LaunchableTarget {
  const factory Manual(final ServerConfig server) = _$ManualImpl;

  ServerConfig get server;

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManualImplCopyWith<_$ManualImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GatewayAgentImplCopyWith<$Res> {
  factory _$$GatewayAgentImplCopyWith(
    _$GatewayAgentImpl value,
    $Res Function(_$GatewayAgentImpl) then,
  ) = __$$GatewayAgentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GatewayAgentBinding binding, GatewaySource gatewaySource});

  $GatewayAgentBindingCopyWith<$Res> get binding;
  $GatewaySourceCopyWith<$Res> get gatewaySource;
}

/// @nodoc
class __$$GatewayAgentImplCopyWithImpl<$Res>
    extends _$LaunchableTargetCopyWithImpl<$Res, _$GatewayAgentImpl>
    implements _$$GatewayAgentImplCopyWith<$Res> {
  __$$GatewayAgentImplCopyWithImpl(
    _$GatewayAgentImpl _value,
    $Res Function(_$GatewayAgentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? binding = null, Object? gatewaySource = null}) {
    return _then(
      _$GatewayAgentImpl(
        binding: null == binding
            ? _value.binding
            : binding // ignore: cast_nullable_to_non_nullable
                  as GatewayAgentBinding,
        gatewaySource: null == gatewaySource
            ? _value.gatewaySource
            : gatewaySource // ignore: cast_nullable_to_non_nullable
                  as GatewaySource,
      ),
    );
  }

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GatewayAgentBindingCopyWith<$Res> get binding {
    return $GatewayAgentBindingCopyWith<$Res>(_value.binding, (value) {
      return _then(_value.copyWith(binding: value));
    });
  }

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GatewaySourceCopyWith<$Res> get gatewaySource {
    return $GatewaySourceCopyWith<$Res>(_value.gatewaySource, (value) {
      return _then(_value.copyWith(gatewaySource: value));
    });
  }
}

/// @nodoc

class _$GatewayAgentImpl implements GatewayAgent {
  const _$GatewayAgentImpl({
    required this.binding,
    required this.gatewaySource,
  });

  @override
  final GatewayAgentBinding binding;
  @override
  final GatewaySource gatewaySource;

  @override
  String toString() {
    return 'LaunchableTarget.gatewayAgent(binding: $binding, gatewaySource: $gatewaySource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GatewayAgentImpl &&
            (identical(other.binding, binding) || other.binding == binding) &&
            (identical(other.gatewaySource, gatewaySource) ||
                other.gatewaySource == gatewaySource));
  }

  @override
  int get hashCode => Object.hash(runtimeType, binding, gatewaySource);

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GatewayAgentImplCopyWith<_$GatewayAgentImpl> get copyWith =>
      __$$GatewayAgentImplCopyWithImpl<_$GatewayAgentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ServerConfig server) manual,
    required TResult Function(
      GatewayAgentBinding binding,
      GatewaySource gatewaySource,
    )
    gatewayAgent,
  }) {
    return gatewayAgent(binding, gatewaySource);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ServerConfig server)? manual,
    TResult? Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
  }) {
    return gatewayAgent?.call(binding, gatewaySource);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ServerConfig server)? manual,
    TResult Function(GatewayAgentBinding binding, GatewaySource gatewaySource)?
    gatewayAgent,
    required TResult orElse(),
  }) {
    if (gatewayAgent != null) {
      return gatewayAgent(binding, gatewaySource);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Manual value) manual,
    required TResult Function(GatewayAgent value) gatewayAgent,
  }) {
    return gatewayAgent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Manual value)? manual,
    TResult? Function(GatewayAgent value)? gatewayAgent,
  }) {
    return gatewayAgent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Manual value)? manual,
    TResult Function(GatewayAgent value)? gatewayAgent,
    required TResult orElse(),
  }) {
    if (gatewayAgent != null) {
      return gatewayAgent(this);
    }
    return orElse();
  }
}

abstract class GatewayAgent implements LaunchableTarget {
  const factory GatewayAgent({
    required final GatewayAgentBinding binding,
    required final GatewaySource gatewaySource,
  }) = _$GatewayAgentImpl;

  GatewayAgentBinding get binding;
  GatewaySource get gatewaySource;

  /// Create a copy of LaunchableTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GatewayAgentImplCopyWith<_$GatewayAgentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
