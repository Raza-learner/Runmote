import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_summary.freezed.dart';
part 'session_summary.g.dart';

@freezed
class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required String id,
    String? title,
    String? cwd,
    DateTime? updatedAt,
  }) = _SessionSummary;

  factory SessionSummary.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryFromJson(json);
}
