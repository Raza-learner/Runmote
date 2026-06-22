// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_call_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextContentImpl _$$TextContentImplFromJson(Map<String, dynamic> json) =>
    _$TextContentImpl(
      json['text'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TextContentImplToJson(_$TextContentImpl instance) =>
    <String, dynamic>{'text': instance.text, 'runtimeType': instance.$type};

_$ImageContentImpl _$$ImageContentImplFromJson(Map<String, dynamic> json) =>
    _$ImageContentImpl(
      data: json['data'] as String,
      mimeType: json['mimeType'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ImageContentImplToJson(_$ImageContentImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'mimeType': instance.mimeType,
      'runtimeType': instance.$type,
    };

_$AudioContentImpl _$$AudioContentImplFromJson(Map<String, dynamic> json) =>
    _$AudioContentImpl(
      json['mimeType'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AudioContentImplToJson(_$AudioContentImpl instance) =>
    <String, dynamic>{
      'mimeType': instance.mimeType,
      'runtimeType': instance.$type,
    };

_$ResourceLinkContentImpl _$$ResourceLinkContentImplFromJson(
  Map<String, dynamic> json,
) => _$ResourceLinkContentImpl(
  name: json['name'] as String,
  uri: json['uri'] as String,
  description: json['description'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ResourceLinkContentImplToJson(
  _$ResourceLinkContentImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'uri': instance.uri,
  'description': instance.description,
  'runtimeType': instance.$type,
};

_$ResourceContentImpl _$$ResourceContentImplFromJson(
  Map<String, dynamic> json,
) => _$ResourceContentImpl(
  uri: json['uri'] as String,
  text: json['text'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ResourceContentImplToJson(
  _$ResourceContentImpl instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'text': instance.text,
  'runtimeType': instance.$type,
};

_$TerminalContentImpl _$$TerminalContentImplFromJson(
  Map<String, dynamic> json,
) => _$TerminalContentImpl(
  json['terminalId'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$TerminalContentImplToJson(
  _$TerminalContentImpl instance,
) => <String, dynamic>{
  'terminalId': instance.terminalId,
  'runtimeType': instance.$type,
};
