// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanEntry _$PlanEntryFromJson(Map<String, dynamic> json) {
  return _PlanEntry.fromJson(json);
}

/// @nodoc
mixin _$PlanEntry {
  String get content => throw _privateConstructorUsedError;
  PlanEntryPriority get priority => throw _privateConstructorUsedError;
  PlanEntryStatus get status => throw _privateConstructorUsedError;

  /// Serializes this PlanEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanEntryCopyWith<PlanEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanEntryCopyWith<$Res> {
  factory $PlanEntryCopyWith(PlanEntry value, $Res Function(PlanEntry) then) =
      _$PlanEntryCopyWithImpl<$Res, PlanEntry>;
  @useResult
  $Res call({
    String content,
    PlanEntryPriority priority,
    PlanEntryStatus status,
  });
}

/// @nodoc
class _$PlanEntryCopyWithImpl<$Res, $Val extends PlanEntry>
    implements $PlanEntryCopyWith<$Res> {
  _$PlanEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? priority = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as PlanEntryPriority,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PlanEntryStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanEntryImplCopyWith<$Res>
    implements $PlanEntryCopyWith<$Res> {
  factory _$$PlanEntryImplCopyWith(
    _$PlanEntryImpl value,
    $Res Function(_$PlanEntryImpl) then,
  ) = __$$PlanEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String content,
    PlanEntryPriority priority,
    PlanEntryStatus status,
  });
}

/// @nodoc
class __$$PlanEntryImplCopyWithImpl<$Res>
    extends _$PlanEntryCopyWithImpl<$Res, _$PlanEntryImpl>
    implements _$$PlanEntryImplCopyWith<$Res> {
  __$$PlanEntryImplCopyWithImpl(
    _$PlanEntryImpl _value,
    $Res Function(_$PlanEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? priority = null,
    Object? status = null,
  }) {
    return _then(
      _$PlanEntryImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as PlanEntryPriority,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PlanEntryStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanEntryImpl implements _PlanEntry {
  const _$PlanEntryImpl({
    required this.content,
    required this.priority,
    required this.status,
  });

  factory _$PlanEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanEntryImplFromJson(json);

  @override
  final String content;
  @override
  final PlanEntryPriority priority;
  @override
  final PlanEntryStatus status;

  @override
  String toString() {
    return 'PlanEntry(content: $content, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanEntryImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, priority, status);

  /// Create a copy of PlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanEntryImplCopyWith<_$PlanEntryImpl> get copyWith =>
      __$$PlanEntryImplCopyWithImpl<_$PlanEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanEntryImplToJson(this);
  }
}

abstract class _PlanEntry implements PlanEntry {
  const factory _PlanEntry({
    required final String content,
    required final PlanEntryPriority priority,
    required final PlanEntryStatus status,
  }) = _$PlanEntryImpl;

  factory _PlanEntry.fromJson(Map<String, dynamic> json) =
      _$PlanEntryImpl.fromJson;

  @override
  String get content;
  @override
  PlanEntryPriority get priority;
  @override
  PlanEntryStatus get status;

  /// Create a copy of PlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanEntryImplCopyWith<_$PlanEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
