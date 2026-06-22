import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_entry.freezed.dart';
part 'plan_entry.g.dart';

@freezed
class PlanEntry with _$PlanEntry {
  const factory PlanEntry({
    required String content,
    required PlanEntryPriority priority,
    required PlanEntryStatus status,
  }) = _PlanEntry;

  factory PlanEntry.fromJson(Map<String, dynamic> json) =>
      _$PlanEntryFromJson(json);
}

enum PlanEntryPriority { high, medium, low }

enum PlanEntryStatus { completed, inProgress, pending }
