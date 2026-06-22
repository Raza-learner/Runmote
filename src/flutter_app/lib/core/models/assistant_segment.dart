import 'package:freezed_annotation/freezed_annotation.dart';
import 'tool_call_display.dart';
import 'plan_entry.dart';

part 'assistant_segment.freezed.dart';
part 'assistant_segment.g.dart';

@freezed
class AssistantSegment with _$AssistantSegment {
  const factory AssistantSegment({
    @Default('') String id,
    @Default(AssistantSegmentKind.message) AssistantSegmentKind kind,
    @Default('') String text,
    ToolCallDisplay? toolCall,
    @Default(<PlanEntry>[]) List<PlanEntry> planEntries,
  }) = _AssistantSegment;

  factory AssistantSegment.fromJson(Map<String, dynamic> json) =>
      _$AssistantSegmentFromJson(json);
}

enum AssistantSegmentKind { message, thought, toolCall, plan }
