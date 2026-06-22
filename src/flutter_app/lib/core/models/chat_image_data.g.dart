// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_image_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatImageDataImpl _$$ChatImageDataImplFromJson(Map<String, dynamic> json) =>
    _$ChatImageDataImpl(
      base64: json['base64'] as String,
      mimeType: json['mimeType'] as String? ?? 'image/jpeg',
    );

Map<String, dynamic> _$$ChatImageDataImplToJson(_$ChatImageDataImpl instance) =>
    <String, dynamic>{'base64': instance.base64, 'mimeType': instance.mimeType};
