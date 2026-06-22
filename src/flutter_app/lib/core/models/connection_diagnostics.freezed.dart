// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_diagnostics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConnectionDiagnostics {
  String? get serverUrl => throw _privateConstructorUsedError;
  int get pendingRequestCount => throw _privateConstructorUsedError;
  List<String> get recentErrors => throw _privateConstructorUsedError;
  int get lastUpdatedAtMs => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionDiagnosticsCopyWith<ConnectionDiagnostics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionDiagnosticsCopyWith<$Res> {
  factory $ConnectionDiagnosticsCopyWith(
    ConnectionDiagnostics value,
    $Res Function(ConnectionDiagnostics) then,
  ) = _$ConnectionDiagnosticsCopyWithImpl<$Res, ConnectionDiagnostics>;
  @useResult
  $Res call({
    String? serverUrl,
    int pendingRequestCount,
    List<String> recentErrors,
    int lastUpdatedAtMs,
  });
}

/// @nodoc
class _$ConnectionDiagnosticsCopyWithImpl<
  $Res,
  $Val extends ConnectionDiagnostics
>
    implements $ConnectionDiagnosticsCopyWith<$Res> {
  _$ConnectionDiagnosticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverUrl = freezed,
    Object? pendingRequestCount = null,
    Object? recentErrors = null,
    Object? lastUpdatedAtMs = null,
  }) {
    return _then(
      _value.copyWith(
            serverUrl: freezed == serverUrl
                ? _value.serverUrl
                : serverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            pendingRequestCount: null == pendingRequestCount
                ? _value.pendingRequestCount
                : pendingRequestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentErrors: null == recentErrors
                ? _value.recentErrors
                : recentErrors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastUpdatedAtMs: null == lastUpdatedAtMs
                ? _value.lastUpdatedAtMs
                : lastUpdatedAtMs // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionDiagnosticsImplCopyWith<$Res>
    implements $ConnectionDiagnosticsCopyWith<$Res> {
  factory _$$ConnectionDiagnosticsImplCopyWith(
    _$ConnectionDiagnosticsImpl value,
    $Res Function(_$ConnectionDiagnosticsImpl) then,
  ) = __$$ConnectionDiagnosticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? serverUrl,
    int pendingRequestCount,
    List<String> recentErrors,
    int lastUpdatedAtMs,
  });
}

/// @nodoc
class __$$ConnectionDiagnosticsImplCopyWithImpl<$Res>
    extends
        _$ConnectionDiagnosticsCopyWithImpl<$Res, _$ConnectionDiagnosticsImpl>
    implements _$$ConnectionDiagnosticsImplCopyWith<$Res> {
  __$$ConnectionDiagnosticsImplCopyWithImpl(
    _$ConnectionDiagnosticsImpl _value,
    $Res Function(_$ConnectionDiagnosticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverUrl = freezed,
    Object? pendingRequestCount = null,
    Object? recentErrors = null,
    Object? lastUpdatedAtMs = null,
  }) {
    return _then(
      _$ConnectionDiagnosticsImpl(
        serverUrl: freezed == serverUrl
            ? _value.serverUrl
            : serverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        pendingRequestCount: null == pendingRequestCount
            ? _value.pendingRequestCount
            : pendingRequestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentErrors: null == recentErrors
            ? _value._recentErrors
            : recentErrors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastUpdatedAtMs: null == lastUpdatedAtMs
            ? _value.lastUpdatedAtMs
            : lastUpdatedAtMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionDiagnosticsImpl implements _ConnectionDiagnostics {
  const _$ConnectionDiagnosticsImpl({
    this.serverUrl,
    this.pendingRequestCount = 0,
    final List<String> recentErrors = const <String>[],
    this.lastUpdatedAtMs = 0,
  }) : _recentErrors = recentErrors;

  @override
  final String? serverUrl;
  @override
  @JsonKey()
  final int pendingRequestCount;
  final List<String> _recentErrors;
  @override
  @JsonKey()
  List<String> get recentErrors {
    if (_recentErrors is EqualUnmodifiableListView) return _recentErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentErrors);
  }

  @override
  @JsonKey()
  final int lastUpdatedAtMs;

  @override
  String toString() {
    return 'ConnectionDiagnostics(serverUrl: $serverUrl, pendingRequestCount: $pendingRequestCount, recentErrors: $recentErrors, lastUpdatedAtMs: $lastUpdatedAtMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionDiagnosticsImpl &&
            (identical(other.serverUrl, serverUrl) ||
                other.serverUrl == serverUrl) &&
            (identical(other.pendingRequestCount, pendingRequestCount) ||
                other.pendingRequestCount == pendingRequestCount) &&
            const DeepCollectionEquality().equals(
              other._recentErrors,
              _recentErrors,
            ) &&
            (identical(other.lastUpdatedAtMs, lastUpdatedAtMs) ||
                other.lastUpdatedAtMs == lastUpdatedAtMs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    serverUrl,
    pendingRequestCount,
    const DeepCollectionEquality().hash(_recentErrors),
    lastUpdatedAtMs,
  );

  /// Create a copy of ConnectionDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionDiagnosticsImplCopyWith<_$ConnectionDiagnosticsImpl>
  get copyWith =>
      __$$ConnectionDiagnosticsImplCopyWithImpl<_$ConnectionDiagnosticsImpl>(
        this,
        _$identity,
      );
}

abstract class _ConnectionDiagnostics implements ConnectionDiagnostics {
  const factory _ConnectionDiagnostics({
    final String? serverUrl,
    final int pendingRequestCount,
    final List<String> recentErrors,
    final int lastUpdatedAtMs,
  }) = _$ConnectionDiagnosticsImpl;

  @override
  String? get serverUrl;
  @override
  int get pendingRequestCount;
  @override
  List<String> get recentErrors;
  @override
  int get lastUpdatedAtMs;

  /// Create a copy of ConnectionDiagnostics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionDiagnosticsImplCopyWith<_$ConnectionDiagnosticsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
