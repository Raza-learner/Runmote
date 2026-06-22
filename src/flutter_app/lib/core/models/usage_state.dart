import 'package:freezed_annotation/freezed_annotation.dart';

part 'usage_state.freezed.dart';

@freezed
class UsageState with _$UsageState {
  const factory UsageState({
    int? totalTokens,
    int? contextWindowTokens,
    double? costAmount,
    String? costCurrency,
  }) = _UsageState;
}
