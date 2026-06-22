import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_diagnostics.freezed.dart';

@freezed
class ConnectionDiagnostics with _$ConnectionDiagnostics {
  const factory ConnectionDiagnostics({
    String? serverUrl,
    @Default(0) int pendingRequestCount,
    @Default(<String>[]) List<String> recentErrors,
    @Default(0) int lastUpdatedAtMs,
  }) = _ConnectionDiagnostics;
}
