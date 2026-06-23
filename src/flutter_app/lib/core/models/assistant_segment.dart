import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_segment.freezed.dart';
part 'assistant_segment.g.dart';

@freezed
class AssistantSegment with _$AssistantSegment {
  const factory AssistantSegment({
    required String id,
    required SegmentKind kind,
    required String text,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AssistantSegment;

  factory AssistantSegment.fromJson(Map<String, dynamic> json) =>
      _$AssistantSegmentFromJson(json);
}

enum SegmentKind {
  message,
  thought,
  toolCall,
  plan;
}
