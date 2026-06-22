// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GatewaySourceImpl _$$GatewaySourceImplFromJson(Map<String, dynamic> json) =>
    _$GatewaySourceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      scheme: json['scheme'] as String? ?? 'http',
      host: json['host'] as String,
      gatewayCredential: json['gatewayCredential'] as String,
      gatewayCredentialExpiresAt: json['gatewayCredentialExpiresAt'] == null
          ? null
          : DateTime.parse(json['gatewayCredentialExpiresAt'] as String),
      gatewayRemoteMode: json['gatewayRemoteMode'] as String?,
    );

Map<String, dynamic> _$$GatewaySourceImplToJson(_$GatewaySourceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scheme': instance.scheme,
      'host': instance.host,
      'gatewayCredential': instance.gatewayCredential,
      'gatewayCredentialExpiresAt': instance.gatewayCredentialExpiresAt
          ?.toIso8601String(),
      'gatewayRemoteMode': instance.gatewayRemoteMode,
    };
