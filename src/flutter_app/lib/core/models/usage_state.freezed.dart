// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usage_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UsageState {
  int? get totalTokens => throw _privateConstructorUsedError;
  int? get contextWindowTokens => throw _privateConstructorUsedError;
  double? get costAmount => throw _privateConstructorUsedError;
  String? get costCurrency => throw _privateConstructorUsedError;

  /// Create a copy of UsageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsageStateCopyWith<UsageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsageStateCopyWith<$Res> {
  factory $UsageStateCopyWith(
    UsageState value,
    $Res Function(UsageState) then,
  ) = _$UsageStateCopyWithImpl<$Res, UsageState>;
  @useResult
  $Res call({
    int? totalTokens,
    int? contextWindowTokens,
    double? costAmount,
    String? costCurrency,
  });
}

/// @nodoc
class _$UsageStateCopyWithImpl<$Res, $Val extends UsageState>
    implements $UsageStateCopyWith<$Res> {
  _$UsageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UsageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTokens = freezed,
    Object? contextWindowTokens = freezed,
    Object? costAmount = freezed,
    Object? costCurrency = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalTokens: freezed == totalTokens
                ? _value.totalTokens
                : totalTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            contextWindowTokens: freezed == contextWindowTokens
                ? _value.contextWindowTokens
                : contextWindowTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            costAmount: freezed == costAmount
                ? _value.costAmount
                : costAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            costCurrency: freezed == costCurrency
                ? _value.costCurrency
                : costCurrency // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UsageStateImplCopyWith<$Res>
    implements $UsageStateCopyWith<$Res> {
  factory _$$UsageStateImplCopyWith(
    _$UsageStateImpl value,
    $Res Function(_$UsageStateImpl) then,
  ) = __$$UsageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? totalTokens,
    int? contextWindowTokens,
    double? costAmount,
    String? costCurrency,
  });
}

/// @nodoc
class __$$UsageStateImplCopyWithImpl<$Res>
    extends _$UsageStateCopyWithImpl<$Res, _$UsageStateImpl>
    implements _$$UsageStateImplCopyWith<$Res> {
  __$$UsageStateImplCopyWithImpl(
    _$UsageStateImpl _value,
    $Res Function(_$UsageStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UsageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTokens = freezed,
    Object? contextWindowTokens = freezed,
    Object? costAmount = freezed,
    Object? costCurrency = freezed,
  }) {
    return _then(
      _$UsageStateImpl(
        totalTokens: freezed == totalTokens
            ? _value.totalTokens
            : totalTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        contextWindowTokens: freezed == contextWindowTokens
            ? _value.contextWindowTokens
            : contextWindowTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        costAmount: freezed == costAmount
            ? _value.costAmount
            : costAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        costCurrency: freezed == costCurrency
            ? _value.costCurrency
            : costCurrency // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UsageStateImpl implements _UsageState {
  const _$UsageStateImpl({
    this.totalTokens,
    this.contextWindowTokens,
    this.costAmount,
    this.costCurrency,
  });

  @override
  final int? totalTokens;
  @override
  final int? contextWindowTokens;
  @override
  final double? costAmount;
  @override
  final String? costCurrency;

  @override
  String toString() {
    return 'UsageState(totalTokens: $totalTokens, contextWindowTokens: $contextWindowTokens, costAmount: $costAmount, costCurrency: $costCurrency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsageStateImpl &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens) &&
            (identical(other.contextWindowTokens, contextWindowTokens) ||
                other.contextWindowTokens == contextWindowTokens) &&
            (identical(other.costAmount, costAmount) ||
                other.costAmount == costAmount) &&
            (identical(other.costCurrency, costCurrency) ||
                other.costCurrency == costCurrency));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalTokens,
    contextWindowTokens,
    costAmount,
    costCurrency,
  );

  /// Create a copy of UsageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsageStateImplCopyWith<_$UsageStateImpl> get copyWith =>
      __$$UsageStateImplCopyWithImpl<_$UsageStateImpl>(this, _$identity);
}

abstract class _UsageState implements UsageState {
  const factory _UsageState({
    final int? totalTokens,
    final int? contextWindowTokens,
    final double? costAmount,
    final String? costCurrency,
  }) = _$UsageStateImpl;

  @override
  int? get totalTokens;
  @override
  int? get contextWindowTokens;
  @override
  double? get costAmount;
  @override
  String? get costCurrency;

  /// Create a copy of UsageState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsageStateImplCopyWith<_$UsageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
