import 'package:freezed_annotation/freezed_annotation.dart';

part 'gateway_source.freezed.dart';
part 'gateway_source.g.dart';

@freezed
class GatewaySource with _$GatewaySource {
  const factory GatewaySource({
    required String id,
    required String name,
    @Default('http') String scheme,
    required String host,
    required String gatewayCredential,
    DateTime? gatewayCredentialExpiresAt,
    String? gatewayRemoteMode,
  }) = _GatewaySource;

  factory GatewaySource.fromJson(Map<String, dynamic> json) =>
      _$GatewaySourceFromJson(json);
}
