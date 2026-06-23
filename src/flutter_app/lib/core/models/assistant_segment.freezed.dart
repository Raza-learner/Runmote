// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_segment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssistantSegment _$AssistantSegmentFromJson(Map<String, dynamic> json) {
  return _AssistantSegment.fromJson(json);
}

/// @nodoc
mixin _$AssistantSegment {
  String get id => throw _privateConstructorUsedError;
  SegmentKind get kind => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this AssistantSegment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantSegmentCopyWith<AssistantSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantSegmentCopyWith<$Res> {
  factory $AssistantSegmentCopyWith(
    AssistantSegment value,
    $Res Function(AssistantSegment) then,
  ) = _$AssistantSegmentCopyWithImpl<$Res, AssistantSegment>;
  @useResult
  $Res call({
    String id,
    SegmentKind kind,
    String text,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$AssistantSegmentCopyWithImpl<$Res, $Val extends AssistantSegment>
    implements $AssistantSegmentCopyWith<$Res> {
  _$AssistantSegmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? text = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as SegmentKind,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssistantSegmentImplCopyWith<$Res>
    implements $AssistantSegmentCopyWith<$Res> {
  factory _$$AssistantSegmentImplCopyWith(
    _$AssistantSegmentImpl value,
    $Res Function(_$AssistantSegmentImpl) then,
  ) = __$$AssistantSegmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    SegmentKind kind,
    String text,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$AssistantSegmentImplCopyWithImpl<$Res>
    extends _$AssistantSegmentCopyWithImpl<$Res, _$AssistantSegmentImpl>
    implements _$$AssistantSegmentImplCopyWith<$Res> {
  __$$AssistantSegmentImplCopyWithImpl(
    _$AssistantSegmentImpl _value,
    $Res Function(_$AssistantSegmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? text = null,
    Object? metadata = null,
  }) {
    return _then(
      _$AssistantSegmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as SegmentKind,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantSegmentImpl implements _AssistantSegment {
  const _$AssistantSegmentImpl({
    required this.id,
    required this.kind,
    required this.text,
    final Map<String, dynamic> metadata = const {},
  }) : _metadata = metadata;

  factory _$AssistantSegmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantSegmentImplFromJson(json);

  @override
  final String id;
  @override
  final SegmentKind kind;
  @override
  final String text;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'AssistantSegment(id: $id, kind: $kind, text: $text, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantSegmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    kind,
    text,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantSegmentImplCopyWith<_$AssistantSegmentImpl> get copyWith =>
      __$$AssistantSegmentImplCopyWithImpl<_$AssistantSegmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantSegmentImplToJson(this);
  }
}

abstract class _AssistantSegment implements AssistantSegment {
  const factory _AssistantSegment({
    required final String id,
    required final SegmentKind kind,
    required final String text,
    final Map<String, dynamic> metadata,
  }) = _$AssistantSegmentImpl;

  factory _AssistantSegment.fromJson(Map<String, dynamic> json) =
      _$AssistantSegmentImpl.fromJson;

  @override
  String get id;
  @override
  SegmentKind get kind;
  @override
  String get text;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantSegmentImplCopyWith<_$AssistantSegmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
