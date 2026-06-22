import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_option.freezed.dart';
part 'config_option.g.dart';

@freezed
sealed class ConfigOption with _$ConfigOption {
  const factory ConfigOption.select({
    required String id,
    required String name,
    String? description,
    @Default('') String category,
    String? currentValue,
    @Default(<ConfigChoice>[]) List<ConfigChoice> choices,
    @Default(<ConfigChoiceGroup>[]) List<ConfigChoiceGroup> groups,
  }) = SelectOption;

  const factory ConfigOption.boolean({
    required String id,
    required String name,
    String? description,
    @Default('') String category,
    @Default(false) bool currentValue,
  }) = BooleanOption;

  const factory ConfigOption.unknown({
    required String id,
    required String name,
    String? description,
    String? kind,
  }) = UnknownOption;

  factory ConfigOption.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionFromJson(json);
}

@freezed
class ConfigChoice with _$ConfigChoice {
  const factory ConfigChoice({
    required String id,
    required String label,
    required String value,
    String? description,
  }) = _ConfigChoice;

  factory ConfigChoice.fromJson(Map<String, dynamic> json) =>
      _$ConfigChoiceFromJson(json);
}

@freezed
class ConfigChoiceGroup with _$ConfigChoiceGroup {
  const factory ConfigChoiceGroup({
    required String id,
    String? label,
    @Default(<ConfigChoice>[]) List<ConfigChoice> choices,
  }) = _ConfigChoiceGroup;

  factory ConfigChoiceGroup.fromJson(Map<String, dynamic> json) =>
      _$ConfigChoiceGroupFromJson(json);
}
