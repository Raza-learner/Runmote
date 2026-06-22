// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatCommand _$ChatCommandFromJson(Map<String, dynamic> json) {
  return _ChatCommand.fromJson(json);
}

/// @nodoc
mixin _$ChatCommand {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this ChatCommand to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatCommandCopyWith<ChatCommand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatCommandCopyWith<$Res> {
  factory $ChatCommandCopyWith(
    ChatCommand value,
    $Res Function(ChatCommand) then,
  ) = _$ChatCommandCopyWithImpl<$Res, ChatCommand>;
  @useResult
  $Res call({String name, String? description});
}

/// @nodoc
class _$ChatCommandCopyWithImpl<$Res, $Val extends ChatCommand>
    implements $ChatCommandCopyWith<$Res> {
  _$ChatCommandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? description = freezed}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ChatCommandImplCopyWith<$Res>
    implements $ChatCommandCopyWith<$Res> {
  factory _$$ChatCommandImplCopyWith(
    _$ChatCommandImpl value,
    $Res Function(_$ChatCommandImpl) then,
  ) = __$$ChatCommandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? description});
}

/// @nodoc
class __$$ChatCommandImplCopyWithImpl<$Res>
    extends _$ChatCommandCopyWithImpl<$Res, _$ChatCommandImpl>
    implements _$$ChatCommandImplCopyWith<$Res> {
  __$$ChatCommandImplCopyWithImpl(
    _$ChatCommandImpl _value,
    $Res Function(_$ChatCommandImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? description = freezed}) {
    return _then(
      _$ChatCommandImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ChatCommandImpl implements _ChatCommand {
  const _$ChatCommandImpl({required this.name, this.description});

  factory _$ChatCommandImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatCommandImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;

  @override
  String toString() {
    return 'ChatCommand(name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatCommandImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description);

  /// Create a copy of ChatCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatCommandImplCopyWith<_$ChatCommandImpl> get copyWith =>
      __$$ChatCommandImplCopyWithImpl<_$ChatCommandImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatCommandImplToJson(this);
  }
}

abstract class _ChatCommand implements ChatCommand {
  const factory _ChatCommand({
    required final String name,
    final String? description,
  }) = _$ChatCommandImpl;

  factory _ChatCommand.fromJson(Map<String, dynamic> json) =
      _$ChatCommandImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;

  /// Create a copy of ChatCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatCommandImplCopyWith<_$ChatCommandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
