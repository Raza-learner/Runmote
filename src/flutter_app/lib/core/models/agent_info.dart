import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_info.freezed.dart';
part 'agent_info.g.dart';

@freezed
class AgentInfo with _$AgentInfo {
  const factory AgentInfo({
    required String name,
    required String version,
  }) = _AgentInfo;

  factory AgentInfo.fromJson(Map<String, dynamic> json) =>
      _$AgentInfoFromJson(json);
}
