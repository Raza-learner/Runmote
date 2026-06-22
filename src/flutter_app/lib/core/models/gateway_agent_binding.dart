import 'package:freezed_annotation/freezed_annotation.dart';
import 'server_config.dart';
import 'gateway_source.dart';

part 'gateway_agent_binding.freezed.dart';

@freezed
class GatewayAgentBinding with _$GatewayAgentBinding {
  const factory GatewayAgentBinding({
    required String id,
    required String name,
    required String gatewaySourceId,
    required String agentId,
    String? preferredAuthMethodId,
  }) = _GatewayAgentBinding;
}

@freezed
sealed class LaunchableTarget with _$LaunchableTarget {
  const factory LaunchableTarget.manual(ServerConfig server) = Manual;
  const factory LaunchableTarget.gatewayAgent({
    required GatewayAgentBinding binding,
    required GatewaySource gatewaySource,
  }) = GatewayAgent;
}
