// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool_call_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ToolCallContent _$ToolCallContentFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'text':
      return TextContent.fromJson(json);
    case 'image':
      return ImageContent.fromJson(json);
    case 'audio':
      return AudioContent.fromJson(json);
    case 'resourceLink':
      return ResourceLinkContent.fromJson(json);
    case 'resource':
      return ResourceContent.fromJson(json);
    case 'terminal':
      return TerminalContent.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'ToolCallContent',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$ToolCallContent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ToolCallContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolCallContentCopyWith<$Res> {
  factory $ToolCallContentCopyWith(
    ToolCallContent value,
    $Res Function(ToolCallContent) then,
  ) = _$ToolCallContentCopyWithImpl<$Res, ToolCallContent>;
}

/// @nodoc
class _$ToolCallContentCopyWithImpl<$Res, $Val extends ToolCallContent>
    implements $ToolCallContentCopyWith<$Res> {
  _$ToolCallContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TextContentImplCopyWith<$Res> {
  factory _$$TextContentImplCopyWith(
    _$TextContentImpl value,
    $Res Function(_$TextContentImpl) then,
  ) = __$$TextContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$TextContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$TextContentImpl>
    implements _$$TextContentImplCopyWith<$Res> {
  __$$TextContentImplCopyWithImpl(
    _$TextContentImpl _value,
    $Res Function(_$TextContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null}) {
    return _then(
      _$TextContentImpl(
        null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TextContentImpl implements TextContent {
  const _$TextContentImpl(this.text, {final String? $type})
    : $type = $type ?? 'text';

  factory _$TextContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextContentImplFromJson(json);

  @override
  final String text;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.text(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextContentImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextContentImplCopyWith<_$TextContentImpl> get copyWith =>
      __$$TextContentImplCopyWithImpl<_$TextContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return text(this.text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return text?.call(this.text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this.text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TextContentImplToJson(this);
  }
}

abstract class TextContent implements ToolCallContent {
  const factory TextContent(final String text) = _$TextContentImpl;

  factory TextContent.fromJson(Map<String, dynamic> json) =
      _$TextContentImpl.fromJson;

  String get text;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextContentImplCopyWith<_$TextContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImageContentImplCopyWith<$Res> {
  factory _$$ImageContentImplCopyWith(
    _$ImageContentImpl value,
    $Res Function(_$ImageContentImpl) then,
  ) = __$$ImageContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String data, String mimeType});
}

/// @nodoc
class __$$ImageContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$ImageContentImpl>
    implements _$$ImageContentImplCopyWith<$Res> {
  __$$ImageContentImplCopyWithImpl(
    _$ImageContentImpl _value,
    $Res Function(_$ImageContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? mimeType = null}) {
    return _then(
      _$ImageContentImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageContentImpl implements ImageContent {
  const _$ImageContentImpl({
    required this.data,
    required this.mimeType,
    final String? $type,
  }) : $type = $type ?? 'image';

  factory _$ImageContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageContentImplFromJson(json);

  @override
  final String data;
  @override
  final String mimeType;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.image(data: $data, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageContentImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data, mimeType);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageContentImplCopyWith<_$ImageContentImpl> get copyWith =>
      __$$ImageContentImplCopyWithImpl<_$ImageContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return image(data, mimeType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return image?.call(data, mimeType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(data, mimeType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageContentImplToJson(this);
  }
}

abstract class ImageContent implements ToolCallContent {
  const factory ImageContent({
    required final String data,
    required final String mimeType,
  }) = _$ImageContentImpl;

  factory ImageContent.fromJson(Map<String, dynamic> json) =
      _$ImageContentImpl.fromJson;

  String get data;
  String get mimeType;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageContentImplCopyWith<_$ImageContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AudioContentImplCopyWith<$Res> {
  factory _$$AudioContentImplCopyWith(
    _$AudioContentImpl value,
    $Res Function(_$AudioContentImpl) then,
  ) = __$$AudioContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String mimeType});
}

/// @nodoc
class __$$AudioContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$AudioContentImpl>
    implements _$$AudioContentImplCopyWith<$Res> {
  __$$AudioContentImplCopyWithImpl(
    _$AudioContentImpl _value,
    $Res Function(_$AudioContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mimeType = null}) {
    return _then(
      _$AudioContentImpl(
        null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioContentImpl implements AudioContent {
  const _$AudioContentImpl(this.mimeType, {final String? $type})
    : $type = $type ?? 'audio';

  factory _$AudioContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioContentImplFromJson(json);

  @override
  final String mimeType;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.audio(mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioContentImpl &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mimeType);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioContentImplCopyWith<_$AudioContentImpl> get copyWith =>
      __$$AudioContentImplCopyWithImpl<_$AudioContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return audio(mimeType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return audio?.call(mimeType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(mimeType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioContentImplToJson(this);
  }
}

abstract class AudioContent implements ToolCallContent {
  const factory AudioContent(final String mimeType) = _$AudioContentImpl;

  factory AudioContent.fromJson(Map<String, dynamic> json) =
      _$AudioContentImpl.fromJson;

  String get mimeType;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioContentImplCopyWith<_$AudioContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResourceLinkContentImplCopyWith<$Res> {
  factory _$$ResourceLinkContentImplCopyWith(
    _$ResourceLinkContentImpl value,
    $Res Function(_$ResourceLinkContentImpl) then,
  ) = __$$ResourceLinkContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, String uri, String? description});
}

/// @nodoc
class __$$ResourceLinkContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$ResourceLinkContentImpl>
    implements _$$ResourceLinkContentImplCopyWith<$Res> {
  __$$ResourceLinkContentImplCopyWithImpl(
    _$ResourceLinkContentImpl _value,
    $Res Function(_$ResourceLinkContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uri = null,
    Object? description = freezed,
  }) {
    return _then(
      _$ResourceLinkContentImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
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
class _$ResourceLinkContentImpl implements ResourceLinkContent {
  const _$ResourceLinkContentImpl({
    required this.name,
    required this.uri,
    this.description,
    final String? $type,
  }) : $type = $type ?? 'resourceLink';

  factory _$ResourceLinkContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResourceLinkContentImplFromJson(json);

  @override
  final String name;
  @override
  final String uri;
  @override
  final String? description;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.resourceLink(name: $name, uri: $uri, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResourceLinkContentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, uri, description);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResourceLinkContentImplCopyWith<_$ResourceLinkContentImpl> get copyWith =>
      __$$ResourceLinkContentImplCopyWithImpl<_$ResourceLinkContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return resourceLink(name, uri, description);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return resourceLink?.call(name, uri, description);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (resourceLink != null) {
      return resourceLink(name, uri, description);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return resourceLink(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return resourceLink?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (resourceLink != null) {
      return resourceLink(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ResourceLinkContentImplToJson(this);
  }
}

abstract class ResourceLinkContent implements ToolCallContent {
  const factory ResourceLinkContent({
    required final String name,
    required final String uri,
    final String? description,
  }) = _$ResourceLinkContentImpl;

  factory ResourceLinkContent.fromJson(Map<String, dynamic> json) =
      _$ResourceLinkContentImpl.fromJson;

  String get name;
  String get uri;
  String? get description;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResourceLinkContentImplCopyWith<_$ResourceLinkContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResourceContentImplCopyWith<$Res> {
  factory _$$ResourceContentImplCopyWith(
    _$ResourceContentImpl value,
    $Res Function(_$ResourceContentImpl) then,
  ) = __$$ResourceContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String uri, String? text});
}

/// @nodoc
class __$$ResourceContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$ResourceContentImpl>
    implements _$$ResourceContentImplCopyWith<$Res> {
  __$$ResourceContentImplCopyWithImpl(
    _$ResourceContentImpl _value,
    $Res Function(_$ResourceContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uri = null, Object? text = freezed}) {
    return _then(
      _$ResourceContentImpl(
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
                  as String,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResourceContentImpl implements ResourceContent {
  const _$ResourceContentImpl({
    required this.uri,
    this.text,
    final String? $type,
  }) : $type = $type ?? 'resource';

  factory _$ResourceContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResourceContentImplFromJson(json);

  @override
  final String uri;
  @override
  final String? text;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.resource(uri: $uri, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResourceContentImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, text);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResourceContentImplCopyWith<_$ResourceContentImpl> get copyWith =>
      __$$ResourceContentImplCopyWithImpl<_$ResourceContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return resource(uri, this.text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return resource?.call(uri, this.text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (resource != null) {
      return resource(uri, this.text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return resource(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return resource?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (resource != null) {
      return resource(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ResourceContentImplToJson(this);
  }
}

abstract class ResourceContent implements ToolCallContent {
  const factory ResourceContent({
    required final String uri,
    final String? text,
  }) = _$ResourceContentImpl;

  factory ResourceContent.fromJson(Map<String, dynamic> json) =
      _$ResourceContentImpl.fromJson;

  String get uri;
  String? get text;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResourceContentImplCopyWith<_$ResourceContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TerminalContentImplCopyWith<$Res> {
  factory _$$TerminalContentImplCopyWith(
    _$TerminalContentImpl value,
    $Res Function(_$TerminalContentImpl) then,
  ) = __$$TerminalContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String terminalId});
}

/// @nodoc
class __$$TerminalContentImplCopyWithImpl<$Res>
    extends _$ToolCallContentCopyWithImpl<$Res, _$TerminalContentImpl>
    implements _$$TerminalContentImplCopyWith<$Res> {
  __$$TerminalContentImplCopyWithImpl(
    _$TerminalContentImpl _value,
    $Res Function(_$TerminalContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? terminalId = null}) {
    return _then(
      _$TerminalContentImpl(
        null == terminalId
            ? _value.terminalId
            : terminalId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TerminalContentImpl implements TerminalContent {
  const _$TerminalContentImpl(this.terminalId, {final String? $type})
    : $type = $type ?? 'terminal';

  factory _$TerminalContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TerminalContentImplFromJson(json);

  @override
  final String terminalId;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ToolCallContent.terminal(terminalId: $terminalId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TerminalContentImpl &&
            (identical(other.terminalId, terminalId) ||
                other.terminalId == terminalId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, terminalId);

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TerminalContentImplCopyWith<_$TerminalContentImpl> get copyWith =>
      __$$TerminalContentImplCopyWithImpl<_$TerminalContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) text,
    required TResult Function(String data, String mimeType) image,
    required TResult Function(String mimeType) audio,
    required TResult Function(String name, String uri, String? description)
    resourceLink,
    required TResult Function(String uri, String? text) resource,
    required TResult Function(String terminalId) terminal,
  }) {
    return terminal(terminalId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? text,
    TResult? Function(String data, String mimeType)? image,
    TResult? Function(String mimeType)? audio,
    TResult? Function(String name, String uri, String? description)?
    resourceLink,
    TResult? Function(String uri, String? text)? resource,
    TResult? Function(String terminalId)? terminal,
  }) {
    return terminal?.call(terminalId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? text,
    TResult Function(String data, String mimeType)? image,
    TResult Function(String mimeType)? audio,
    TResult Function(String name, String uri, String? description)?
    resourceLink,
    TResult Function(String uri, String? text)? resource,
    TResult Function(String terminalId)? terminal,
    required TResult orElse(),
  }) {
    if (terminal != null) {
      return terminal(terminalId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextContent value) text,
    required TResult Function(ImageContent value) image,
    required TResult Function(AudioContent value) audio,
    required TResult Function(ResourceLinkContent value) resourceLink,
    required TResult Function(ResourceContent value) resource,
    required TResult Function(TerminalContent value) terminal,
  }) {
    return terminal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextContent value)? text,
    TResult? Function(ImageContent value)? image,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(ResourceLinkContent value)? resourceLink,
    TResult? Function(ResourceContent value)? resource,
    TResult? Function(TerminalContent value)? terminal,
  }) {
    return terminal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextContent value)? text,
    TResult Function(ImageContent value)? image,
    TResult Function(AudioContent value)? audio,
    TResult Function(ResourceLinkContent value)? resourceLink,
    TResult Function(ResourceContent value)? resource,
    TResult Function(TerminalContent value)? terminal,
    required TResult orElse(),
  }) {
    if (terminal != null) {
      return terminal(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TerminalContentImplToJson(this);
  }
}

abstract class TerminalContent implements ToolCallContent {
  const factory TerminalContent(final String terminalId) =
      _$TerminalContentImpl;

  factory TerminalContent.fromJson(Map<String, dynamic> json) =
      _$TerminalContentImpl.fromJson;

  String get terminalId;

  /// Create a copy of ToolCallContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TerminalContentImplCopyWith<_$TerminalContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
