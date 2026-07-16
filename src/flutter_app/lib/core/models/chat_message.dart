import 'package:freezed_annotation/freezed_annotation.dart';
import 'assistant_segment.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatMessageRole role,
    required String content,
    @Default([])
    // ignore: invalid_annotation_target
    @JsonKey(toJson: _segmentsToJson)
    List<AssistantSegment> segments,
    @Default(false) bool isStreaming,
    required int createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

List<Map<String, dynamic>> _segmentsToJson(List<AssistantSegment> segments) =>
    segments.map((s) => s.toJson()).toList();

enum ChatMessageRole { user, assistant }
