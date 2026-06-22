import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_state.freezed.dart';

@freezed
sealed class AcpConnectionState with _$AcpConnectionState {
  const factory AcpConnectionState.disconnected() = Disconnected;
  const factory AcpConnectionState.connecting() = Connecting;
  const factory AcpConnectionState.connected() = Connected;
  const factory AcpConnectionState.reconnecting() = Reconnecting;
  const factory AcpConnectionState.failed(String? errorMessage) = Failed;
}
