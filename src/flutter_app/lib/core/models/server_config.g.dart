// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServerConfigImpl _$$ServerConfigImplFromJson(Map<String, dynamic> json) =>
    _$ServerConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      scheme: json['scheme'] as String? ?? 'ws',
      host: json['host'] as String,
      token: json['token'] as String? ?? '',
      preferredAuthMethodId: json['preferredAuthMethodId'] as String?,
    );

Map<String, dynamic> _$$ServerConfigImplToJson(_$ServerConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scheme': instance.scheme,
      'host': instance.host,
      'token': instance.token,
      'preferredAuthMethodId': instance.preferredAuthMethodId,
    };
