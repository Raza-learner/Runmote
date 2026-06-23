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
    @Default([]) List<AssistantSegment> segments,
    @Default(false) bool isStreaming,
    required int createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

enum ChatMessageRole { user, assistant }
