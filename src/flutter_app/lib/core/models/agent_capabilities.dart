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
    @Default(false) bool supportsDelete,
  }) = _AgentCapabilities;

  factory AgentCapabilities.fromJson(Map<String, dynamic> json) =>
      _parseAcpCapabilities(json);
}

AgentCapabilities _parseAcpCapabilities(Map<String, dynamic> json) {
  final promptCaps = json['promptCapabilities'] as Map<String, dynamic>?;
  final sessionCaps =
      json['sessionCapabilities'] as Map<String, dynamic>?;
  return AgentCapabilities(
    canSendImages: promptCaps?['image'] as bool? ?? false,
    supportsEmbeddedContext:
        promptCaps?['embeddedContext'] as bool? ?? false,
    supportsSessionList: sessionCaps?.containsKey('list') ?? false,
    supportsLoadSession: json['loadSession'] as bool? ?? false,
    supportsDelete: sessionCaps?.containsKey('delete') ?? false,
  );
}
