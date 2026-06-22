// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PermissionOption _$PermissionOptionFromJson(Map<String, dynamic> json) {
  return _PermissionOption.fromJson(json);
}

/// @nodoc
mixin _$PermissionOption {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;

  /// Serializes this PermissionOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PermissionOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionOptionCopyWith<PermissionOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionOptionCopyWith<$Res> {
  factory $PermissionOptionCopyWith(
    PermissionOption value,
    $Res Function(PermissionOption) then,
  ) = _$PermissionOptionCopyWithImpl<$Res, PermissionOption>;
  @useResult
  $Res call({String id, String label, String kind});
}

/// @nodoc
class _$PermissionOptionCopyWithImpl<$Res, $Val extends PermissionOption>
    implements $PermissionOptionCopyWith<$Res> {
  _$PermissionOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? label = null, Object? kind = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PermissionOptionImplCopyWith<$Res>
    implements $PermissionOptionCopyWith<$Res> {
  factory _$$PermissionOptionImplCopyWith(
    _$PermissionOptionImpl value,
    $Res Function(_$PermissionOptionImpl) then,
  ) = __$$PermissionOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String label, String kind});
}

/// @nodoc
class __$$PermissionOptionImplCopyWithImpl<$Res>
    extends _$PermissionOptionCopyWithImpl<$Res, _$PermissionOptionImpl>
    implements _$$PermissionOptionImplCopyWith<$Res> {
  __$$PermissionOptionImplCopyWithImpl(
    _$PermissionOptionImpl _value,
    $Res Function(_$PermissionOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PermissionOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? label = null, Object? kind = null}) {
    return _then(
      _$PermissionOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PermissionOptionImpl implements _PermissionOption {
  const _$PermissionOptionImpl({
    required this.id,
    required this.label,
    required this.kind,
  });

  factory _$PermissionOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PermissionOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String kind;

  @override
  String toString() {
    return 'PermissionOption(id: $id, label: $label, kind: $kind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.kind, kind) || other.kind == kind));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, kind);

  /// Create a copy of PermissionOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionOptionImplCopyWith<_$PermissionOptionImpl> get copyWith =>
      __$$PermissionOptionImplCopyWithImpl<_$PermissionOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionOptionImplToJson(this);
  }
}

abstract class _PermissionOption implements PermissionOption {
  const factory _PermissionOption({
    required final String id,
    required final String label,
    required final String kind,
  }) = _$PermissionOptionImpl;

  factory _PermissionOption.fromJson(Map<String, dynamic> json) =
      _$PermissionOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get kind;

  /// Create a copy of PermissionOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionOptionImplCopyWith<_$PermissionOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
