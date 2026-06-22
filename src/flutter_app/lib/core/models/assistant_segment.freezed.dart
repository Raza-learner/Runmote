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
  AssistantSegmentKind get kind => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  ToolCallDisplay? get toolCall => throw _privateConstructorUsedError;
  List<PlanEntry> get planEntries => throw _privateConstructorUsedError;

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
    AssistantSegmentKind kind,
    String text,
    ToolCallDisplay? toolCall,
    List<PlanEntry> planEntries,
  });

  $ToolCallDisplayCopyWith<$Res>? get toolCall;
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
    Object? toolCall = freezed,
    Object? planEntries = null,
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
                      as AssistantSegmentKind,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            toolCall: freezed == toolCall
                ? _value.toolCall
                : toolCall // ignore: cast_nullable_to_non_nullable
                      as ToolCallDisplay?,
            planEntries: null == planEntries
                ? _value.planEntries
                : planEntries // ignore: cast_nullable_to_non_nullable
                      as List<PlanEntry>,
          )
          as $Val,
    );
  }

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ToolCallDisplayCopyWith<$Res>? get toolCall {
    if (_value.toolCall == null) {
      return null;
    }

    return $ToolCallDisplayCopyWith<$Res>(_value.toolCall!, (value) {
      return _then(_value.copyWith(toolCall: value) as $Val);
    });
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
    AssistantSegmentKind kind,
    String text,
    ToolCallDisplay? toolCall,
    List<PlanEntry> planEntries,
  });

  @override
  $ToolCallDisplayCopyWith<$Res>? get toolCall;
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
    Object? toolCall = freezed,
    Object? planEntries = null,
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
                  as AssistantSegmentKind,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        toolCall: freezed == toolCall
            ? _value.toolCall
            : toolCall // ignore: cast_nullable_to_non_nullable
                  as ToolCallDisplay?,
        planEntries: null == planEntries
            ? _value._planEntries
            : planEntries // ignore: cast_nullable_to_non_nullable
                  as List<PlanEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantSegmentImpl implements _AssistantSegment {
  const _$AssistantSegmentImpl({
    this.id = '',
    this.kind = AssistantSegmentKind.message,
    this.text = '',
    this.toolCall,
    final List<PlanEntry> planEntries = const <PlanEntry>[],
  }) : _planEntries = planEntries;

  factory _$AssistantSegmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantSegmentImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final AssistantSegmentKind kind;
  @override
  @JsonKey()
  final String text;
  @override
  final ToolCallDisplay? toolCall;
  final List<PlanEntry> _planEntries;
  @override
  @JsonKey()
  List<PlanEntry> get planEntries {
    if (_planEntries is EqualUnmodifiableListView) return _planEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planEntries);
  }

  @override
  String toString() {
    return 'AssistantSegment(id: $id, kind: $kind, text: $text, toolCall: $toolCall, planEntries: $planEntries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantSegmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.toolCall, toolCall) ||
                other.toolCall == toolCall) &&
            const DeepCollectionEquality().equals(
              other._planEntries,
              _planEntries,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    kind,
    text,
    toolCall,
    const DeepCollectionEquality().hash(_planEntries),
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
    final String id,
    final AssistantSegmentKind kind,
    final String text,
    final ToolCallDisplay? toolCall,
    final List<PlanEntry> planEntries,
  }) = _$AssistantSegmentImpl;

  factory _AssistantSegment.fromJson(Map<String, dynamic> json) =
      _$AssistantSegmentImpl.fromJson;

  @override
  String get id;
  @override
  AssistantSegmentKind get kind;
  @override
  String get text;
  @override
  ToolCallDisplay? get toolCall;
  @override
  List<PlanEntry> get planEntries;

  /// Create a copy of AssistantSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantSegmentImplCopyWith<_$AssistantSegmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
