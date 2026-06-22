// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_image_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatImageData _$ChatImageDataFromJson(Map<String, dynamic> json) {
  return _ChatImageData.fromJson(json);
}

/// @nodoc
mixin _$ChatImageData {
  String get base64 => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;

  /// Serializes this ChatImageData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatImageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatImageDataCopyWith<ChatImageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatImageDataCopyWith<$Res> {
  factory $ChatImageDataCopyWith(
    ChatImageData value,
    $Res Function(ChatImageData) then,
  ) = _$ChatImageDataCopyWithImpl<$Res, ChatImageData>;
  @useResult
  $Res call({String base64, String mimeType});
}

/// @nodoc
class _$ChatImageDataCopyWithImpl<$Res, $Val extends ChatImageData>
    implements $ChatImageDataCopyWith<$Res> {
  _$ChatImageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatImageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? base64 = null, Object? mimeType = null}) {
    return _then(
      _value.copyWith(
            base64: null == base64
                ? _value.base64
                : base64 // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatImageDataImplCopyWith<$Res>
    implements $ChatImageDataCopyWith<$Res> {
  factory _$$ChatImageDataImplCopyWith(
    _$ChatImageDataImpl value,
    $Res Function(_$ChatImageDataImpl) then,
  ) = __$$ChatImageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String base64, String mimeType});
}

/// @nodoc
class __$$ChatImageDataImplCopyWithImpl<$Res>
    extends _$ChatImageDataCopyWithImpl<$Res, _$ChatImageDataImpl>
    implements _$$ChatImageDataImplCopyWith<$Res> {
  __$$ChatImageDataImplCopyWithImpl(
    _$ChatImageDataImpl _value,
    $Res Function(_$ChatImageDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatImageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? base64 = null, Object? mimeType = null}) {
    return _then(
      _$ChatImageDataImpl(
        base64: null == base64
            ? _value.base64
            : base64 // ignore: cast_nullable_to_non_nullable
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
class _$ChatImageDataImpl implements _ChatImageData {
  const _$ChatImageDataImpl({
    required this.base64,
    this.mimeType = 'image/jpeg',
  });

  factory _$ChatImageDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatImageDataImplFromJson(json);

  @override
  final String base64;
  @override
  @JsonKey()
  final String mimeType;

  @override
  String toString() {
    return 'ChatImageData(base64: $base64, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatImageDataImpl &&
            (identical(other.base64, base64) || other.base64 == base64) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, base64, mimeType);

  /// Create a copy of ChatImageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatImageDataImplCopyWith<_$ChatImageDataImpl> get copyWith =>
      __$$ChatImageDataImplCopyWithImpl<_$ChatImageDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatImageDataImplToJson(this);
  }
}

abstract class _ChatImageData implements ChatImageData {
  const factory _ChatImageData({
    required final String base64,
    final String mimeType,
  }) = _$ChatImageDataImpl;

  factory _ChatImageData.fromJson(Map<String, dynamic> json) =
      _$ChatImageDataImpl.fromJson;

  @override
  String get base64;
  @override
  String get mimeType;

  /// Create a copy of ChatImageData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatImageDataImplCopyWith<_$ChatImageDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
