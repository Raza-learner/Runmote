// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanEntryImpl _$$PlanEntryImplFromJson(Map<String, dynamic> json) =>
    _$PlanEntryImpl(
      content: json['content'] as String,
      priority: $enumDecode(_$PlanEntryPriorityEnumMap, json['priority']),
      status: $enumDecode(_$PlanEntryStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$PlanEntryImplToJson(_$PlanEntryImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'priority': _$PlanEntryPriorityEnumMap[instance.priority]!,
      'status': _$PlanEntryStatusEnumMap[instance.status]!,
    };

const _$PlanEntryPriorityEnumMap = {
  PlanEntryPriority.high: 'high',
  PlanEntryPriority.medium: 'medium',
  PlanEntryPriority.low: 'low',
};

const _$PlanEntryStatusEnumMap = {
  PlanEntryStatus.completed: 'completed',
  PlanEntryStatus.inProgress: 'inProgress',
  PlanEntryStatus.pending: 'pending',
};
