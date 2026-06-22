// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssistantSegmentImpl _$$AssistantSegmentImplFromJson(
  Map<String, dynamic> json,
) => _$AssistantSegmentImpl(
  id: json['id'] as String? ?? '',
  kind:
      $enumDecodeNullable(_$AssistantSegmentKindEnumMap, json['kind']) ??
      AssistantSegmentKind.message,
  text: json['text'] as String? ?? '',
  toolCall: json['toolCall'] == null
      ? null
      : ToolCallDisplay.fromJson(json['toolCall'] as Map<String, dynamic>),
  planEntries:
      (json['planEntries'] as List<dynamic>?)
          ?.map((e) => PlanEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PlanEntry>[],
);

Map<String, dynamic> _$$AssistantSegmentImplToJson(
  _$AssistantSegmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': _$AssistantSegmentKindEnumMap[instance.kind]!,
  'text': instance.text,
  'toolCall': instance.toolCall,
  'planEntries': instance.planEntries,
};

const _$AssistantSegmentKindEnumMap = {
  AssistantSegmentKind.message: 'message',
  AssistantSegmentKind.thought: 'thought',
  AssistantSegmentKind.toolCall: 'toolCall',
  AssistantSegmentKind.plan: 'plan',
};
