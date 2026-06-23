// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssistantSegmentImpl _$$AssistantSegmentImplFromJson(
  Map<String, dynamic> json,
) => _$AssistantSegmentImpl(
  id: json['id'] as String,
  kind: $enumDecode(_$SegmentKindEnumMap, json['kind']),
  text: json['text'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$AssistantSegmentImplToJson(
  _$AssistantSegmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': _$SegmentKindEnumMap[instance.kind]!,
  'text': instance.text,
  'metadata': instance.metadata,
};

const _$SegmentKindEnumMap = {
  SegmentKind.message: 'message',
  SegmentKind.thought: 'thought',
  SegmentKind.toolCall: 'toolCall',
  SegmentKind.plan: 'plan',
};
