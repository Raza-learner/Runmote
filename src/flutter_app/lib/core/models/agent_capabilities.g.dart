// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentCapabilitiesImpl _$$AgentCapabilitiesImplFromJson(
  Map<String, dynamic> json,
) => _$AgentCapabilitiesImpl(
  canSendImages: json['canSendImages'] as bool? ?? false,
  supportsEmbeddedContext: json['supportsEmbeddedContext'] as bool? ?? false,
  supportsSessionList: json['supportsSessionList'] as bool? ?? false,
  supportsLoadSession: json['supportsLoadSession'] as bool? ?? false,
);

Map<String, dynamic> _$$AgentCapabilitiesImplToJson(
  _$AgentCapabilitiesImpl instance,
) => <String, dynamic>{
  'canSendImages': instance.canSendImages,
  'supportsEmbeddedContext': instance.supportsEmbeddedContext,
  'supportsSessionList': instance.supportsSessionList,
  'supportsLoadSession': instance.supportsLoadSession,
};
