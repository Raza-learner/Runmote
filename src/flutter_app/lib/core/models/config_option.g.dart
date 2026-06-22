// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SelectOptionImpl _$$SelectOptionImplFromJson(Map<String, dynamic> json) =>
    _$SelectOptionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      currentValue: json['currentValue'] as String?,
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map((e) => ConfigChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ConfigChoice>[],
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map(
                (e) => ConfigChoiceGroup.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ConfigChoiceGroup>[],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SelectOptionImplToJson(_$SelectOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'currentValue': instance.currentValue,
      'choices': instance.choices,
      'groups': instance.groups,
      'runtimeType': instance.$type,
    };

_$BooleanOptionImpl _$$BooleanOptionImplFromJson(Map<String, dynamic> json) =>
    _$BooleanOptionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      currentValue: json['currentValue'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BooleanOptionImplToJson(_$BooleanOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'currentValue': instance.currentValue,
      'runtimeType': instance.$type,
    };

_$UnknownOptionImpl _$$UnknownOptionImplFromJson(Map<String, dynamic> json) =>
    _$UnknownOptionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      kind: json['kind'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$UnknownOptionImplToJson(_$UnknownOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'kind': instance.kind,
      'runtimeType': instance.$type,
    };

_$ConfigChoiceImpl _$$ConfigChoiceImplFromJson(Map<String, dynamic> json) =>
    _$ConfigChoiceImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$ConfigChoiceImplToJson(_$ConfigChoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'value': instance.value,
      'description': instance.description,
    };

_$ConfigChoiceGroupImpl _$$ConfigChoiceGroupImplFromJson(
  Map<String, dynamic> json,
) => _$ConfigChoiceGroupImpl(
  id: json['id'] as String,
  label: json['label'] as String?,
  choices:
      (json['choices'] as List<dynamic>?)
          ?.map((e) => ConfigChoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ConfigChoice>[],
);

Map<String, dynamic> _$$ConfigChoiceGroupImplToJson(
  _$ConfigChoiceGroupImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'choices': instance.choices,
};
