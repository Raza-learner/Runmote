// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String? ?? '',
      role:
          $enumDecodeNullable(_$ChatMessageRoleEnumMap, json['role']) ??
          ChatMessageRole.user,
      content: json['content'] as String? ?? '',
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((e) => AssistantSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AssistantSegment>[],
      isStreaming: json['isStreaming'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ChatImageData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatImageData>[],
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatMessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'segments': instance.segments,
      'isStreaming': instance.isStreaming,
      'isError': instance.isError,
      'images': instance.images,
      'createdAt': instance.createdAt,
    };

const _$ChatMessageRoleEnumMap = {
  ChatMessageRole.user: 'user',
  ChatMessageRole.assistant: 'assistant',
  ChatMessageRole.system: 'system',
};
