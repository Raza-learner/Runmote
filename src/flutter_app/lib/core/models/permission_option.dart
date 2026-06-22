import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_option.freezed.dart';
part 'permission_option.g.dart';

@freezed
class PermissionOption with _$PermissionOption {
  const factory PermissionOption({
    required String id,
    required String label,
    required String kind,
  }) = _PermissionOption;

  factory PermissionOption.fromJson(Map<String, dynamic> json) =>
      _$PermissionOptionFromJson(json);
}
