// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      role: $enumDecode(_$ChatMessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((e) => AssistantSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isStreaming: json['isStreaming'] as bool? ?? false,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatMessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'segments': _segmentsToJson(instance.segments),
      'isStreaming': instance.isStreaming,
      'createdAt': instance.createdAt,
    };

const _$ChatMessageRoleEnumMap = {
  ChatMessageRole.user: 'user',
  ChatMessageRole.assistant: 'assistant',
};
