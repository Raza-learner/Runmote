// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_call_display.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToolCallDisplayImpl _$$ToolCallDisplayImplFromJson(
  Map<String, dynamic> json,
) => _$ToolCallDisplayImpl(
  toolCallId: json['toolCallId'] as String?,
  title: json['title'] as String? ?? '',
  kind: $enumDecodeNullable(_$ToolKindEnumMap, json['kind']),
  status: $enumDecodeNullable(_$ToolCallStatusEnumMap, json['status']),
  content:
      (json['content'] as List<dynamic>?)
          ?.map((e) => ToolCallContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ToolCallContent>[],
  rawInput: json['rawInput'] as String?,
  rawOutput: json['rawOutput'] as String?,
  permissionOptions:
      (json['permissionOptions'] as List<dynamic>?)
          ?.map((e) => PermissionOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PermissionOption>[],
  permissionRequestId: json['permissionRequestId'] as String?,
);

Map<String, dynamic> _$$ToolCallDisplayImplToJson(
  _$ToolCallDisplayImpl instance,
) => <String, dynamic>{
  'toolCallId': instance.toolCallId,
  'title': instance.title,
  'kind': _$ToolKindEnumMap[instance.kind],
  'status': _$ToolCallStatusEnumMap[instance.status],
  'content': instance.content,
  'rawInput': instance.rawInput,
  'rawOutput': instance.rawOutput,
  'permissionOptions': instance.permissionOptions,
  'permissionRequestId': instance.permissionRequestId,
};

const _$ToolKindEnumMap = {
  ToolKind.read: 'read',
  ToolKind.edit: 'edit',
  ToolKind.delete: 'delete',
  ToolKind.move: 'move',
  ToolKind.search: 'search',
  ToolKind.execute: 'execute',
  ToolKind.think: 'think',
  ToolKind.fetch: 'fetch',
  ToolKind.switchMode: 'switchMode',
  ToolKind.other: 'other',
};

const _$ToolCallStatusEnumMap = {
  ToolCallStatus.pending: 'pending',
  ToolCallStatus.inProgress: 'inProgress',
  ToolCallStatus.completed: 'completed',
  ToolCallStatus.failed: 'failed',
};
