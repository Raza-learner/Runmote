// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool_call_display.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ToolCallDisplay _$ToolCallDisplayFromJson(Map<String, dynamic> json) {
  return _ToolCallDisplay.fromJson(json);
}

/// @nodoc
mixin _$ToolCallDisplay {
  String? get toolCallId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  ToolKind? get kind => throw _privateConstructorUsedError;
  ToolCallStatus? get status => throw _privateConstructorUsedError;
  List<ToolCallContent> get content => throw _privateConstructorUsedError;
  String? get rawInput => throw _privateConstructorUsedError;
  String? get rawOutput => throw _privateConstructorUsedError;
  List<PermissionOption> get permissionOptions =>
      throw _privateConstructorUsedError;
  String? get permissionRequestId => throw _privateConstructorUsedError;

  /// Serializes this ToolCallDisplay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolCallDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolCallDisplayCopyWith<ToolCallDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolCallDisplayCopyWith<$Res> {
  factory $ToolCallDisplayCopyWith(
    ToolCallDisplay value,
    $Res Function(ToolCallDisplay) then,
  ) = _$ToolCallDisplayCopyWithImpl<$Res, ToolCallDisplay>;
  @useResult
  $Res call({
    String? toolCallId,
    String title,
    ToolKind? kind,
    ToolCallStatus? status,
    List<ToolCallContent> content,
    String? rawInput,
    String? rawOutput,
    List<PermissionOption> permissionOptions,
    String? permissionRequestId,
  });
}

/// @nodoc
class _$ToolCallDisplayCopyWithImpl<$Res, $Val extends ToolCallDisplay>
    implements $ToolCallDisplayCopyWith<$Res> {
  _$ToolCallDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolCallDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolCallId = freezed,
    Object? title = null,
    Object? kind = freezed,
    Object? status = freezed,
    Object? content = null,
    Object? rawInput = freezed,
    Object? rawOutput = freezed,
    Object? permissionOptions = null,
    Object? permissionRequestId = freezed,
  }) {
    return _then(
      _value.copyWith(
            toolCallId: freezed == toolCallId
                ? _value.toolCallId
                : toolCallId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: freezed == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as ToolKind?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ToolCallStatus?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<ToolCallContent>,
            rawInput: freezed == rawInput
                ? _value.rawInput
                : rawInput // ignore: cast_nullable_to_non_nullable
                      as String?,
            rawOutput: freezed == rawOutput
                ? _value.rawOutput
                : rawOutput // ignore: cast_nullable_to_non_nullable
                      as String?,
            permissionOptions: null == permissionOptions
                ? _value.permissionOptions
                : permissionOptions // ignore: cast_nullable_to_non_nullable
                      as List<PermissionOption>,
            permissionRequestId: freezed == permissionRequestId
                ? _value.permissionRequestId
                : permissionRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ToolCallDisplayImplCopyWith<$Res>
    implements $ToolCallDisplayCopyWith<$Res> {
  factory _$$ToolCallDisplayImplCopyWith(
    _$ToolCallDisplayImpl value,
    $Res Function(_$ToolCallDisplayImpl) then,
  ) = __$$ToolCallDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? toolCallId,
    String title,
    ToolKind? kind,
    ToolCallStatus? status,
    List<ToolCallContent> content,
    String? rawInput,
    String? rawOutput,
    List<PermissionOption> permissionOptions,
    String? permissionRequestId,
  });
}

/// @nodoc
class __$$ToolCallDisplayImplCopyWithImpl<$Res>
    extends _$ToolCallDisplayCopyWithImpl<$Res, _$ToolCallDisplayImpl>
    implements _$$ToolCallDisplayImplCopyWith<$Res> {
  __$$ToolCallDisplayImplCopyWithImpl(
    _$ToolCallDisplayImpl _value,
    $Res Function(_$ToolCallDisplayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolCallId = freezed,
    Object? title = null,
    Object? kind = freezed,
    Object? status = freezed,
    Object? content = null,
    Object? rawInput = freezed,
    Object? rawOutput = freezed,
    Object? permissionOptions = null,
    Object? permissionRequestId = freezed,
  }) {
    return _then(
      _$ToolCallDisplayImpl(
        toolCallId: freezed == toolCallId
            ? _value.toolCallId
            : toolCallId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: freezed == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as ToolKind?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ToolCallStatus?,
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<ToolCallContent>,
        rawInput: freezed == rawInput
            ? _value.rawInput
            : rawInput // ignore: cast_nullable_to_non_nullable
                  as String?,
        rawOutput: freezed == rawOutput
            ? _value.rawOutput
            : rawOutput // ignore: cast_nullable_to_non_nullable
                  as String?,
        permissionOptions: null == permissionOptions
            ? _value._permissionOptions
            : permissionOptions // ignore: cast_nullable_to_non_nullable
                  as List<PermissionOption>,
        permissionRequestId: freezed == permissionRequestId
            ? _value.permissionRequestId
            : permissionRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolCallDisplayImpl implements _ToolCallDisplay {
  const _$ToolCallDisplayImpl({
    this.toolCallId,
    this.title = '',
    this.kind,
    this.status,
    final List<ToolCallContent> content = const <ToolCallContent>[],
    this.rawInput,
    this.rawOutput,
    final List<PermissionOption> permissionOptions = const <PermissionOption>[],
    this.permissionRequestId,
  }) : _content = content,
       _permissionOptions = permissionOptions;

  factory _$ToolCallDisplayImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolCallDisplayImplFromJson(json);

  @override
  final String? toolCallId;
  @override
  @JsonKey()
  final String title;
  @override
  final ToolKind? kind;
  @override
  final ToolCallStatus? status;
  final List<ToolCallContent> _content;
  @override
  @JsonKey()
  List<ToolCallContent> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final String? rawInput;
  @override
  final String? rawOutput;
  final List<PermissionOption> _permissionOptions;
  @override
  @JsonKey()
  List<PermissionOption> get permissionOptions {
    if (_permissionOptions is EqualUnmodifiableListView)
      return _permissionOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissionOptions);
  }

  @override
  final String? permissionRequestId;

  @override
  String toString() {
    return 'ToolCallDisplay(toolCallId: $toolCallId, title: $title, kind: $kind, status: $status, content: $content, rawInput: $rawInput, rawOutput: $rawOutput, permissionOptions: $permissionOptions, permissionRequestId: $permissionRequestId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolCallDisplayImpl &&
            (identical(other.toolCallId, toolCallId) ||
                other.toolCallId == toolCallId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.rawInput, rawInput) ||
                other.rawInput == rawInput) &&
            (identical(other.rawOutput, rawOutput) ||
                other.rawOutput == rawOutput) &&
            const DeepCollectionEquality().equals(
              other._permissionOptions,
              _permissionOptions,
            ) &&
            (identical(other.permissionRequestId, permissionRequestId) ||
                other.permissionRequestId == permissionRequestId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    toolCallId,
    title,
    kind,
    status,
    const DeepCollectionEquality().hash(_content),
    rawInput,
    rawOutput,
    const DeepCollectionEquality().hash(_permissionOptions),
    permissionRequestId,
  );

  /// Create a copy of ToolCallDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolCallDisplayImplCopyWith<_$ToolCallDisplayImpl> get copyWith =>
      __$$ToolCallDisplayImplCopyWithImpl<_$ToolCallDisplayImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolCallDisplayImplToJson(this);
  }
}

abstract class _ToolCallDisplay implements ToolCallDisplay {
  const factory _ToolCallDisplay({
    final String? toolCallId,
    final String title,
    final ToolKind? kind,
    final ToolCallStatus? status,
    final List<ToolCallContent> content,
    final String? rawInput,
    final String? rawOutput,
    final List<PermissionOption> permissionOptions,
    final String? permissionRequestId,
  }) = _$ToolCallDisplayImpl;

  factory _ToolCallDisplay.fromJson(Map<String, dynamic> json) =
      _$ToolCallDisplayImpl.fromJson;

  @override
  String? get toolCallId;
  @override
  String get title;
  @override
  ToolKind? get kind;
  @override
  ToolCallStatus? get status;
  @override
  List<ToolCallContent> get content;
  @override
  String? get rawInput;
  @override
  String? get rawOutput;
  @override
  List<PermissionOption> get permissionOptions;
  @override
  String? get permissionRequestId;

  /// Create a copy of ToolCallDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolCallDisplayImplCopyWith<_$ToolCallDisplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
