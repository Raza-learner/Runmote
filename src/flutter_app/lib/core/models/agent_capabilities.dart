import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_capabilities.freezed.dart';
part 'agent_capabilities.g.dart';

@freezed
class AgentCapabilities with _$AgentCapabilities {
  const factory AgentCapabilities({
    @Default(false) bool canSendImages,
    @Default(false) bool supportsEmbeddedContext,
    @Default(false) bool supportsSessionList,
    @Default(false) bool supportsLoadSession,
  }) = _AgentCapabilities;

  factory AgentCapabilities.fromJson(Map<String, dynamic> json) =>
      _$AgentCapabilitiesFromJson(json);
}
