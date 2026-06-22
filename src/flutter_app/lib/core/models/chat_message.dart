import 'package:freezed_annotation/freezed_annotation.dart';
import 'assistant_segment.dart';
import 'chat_image_data.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @Default('') String id,
    @Default(ChatMessageRole.user) ChatMessageRole role,
    @Default('') String content,
    @Default(<AssistantSegment>[]) List<AssistantSegment> segments,
    @Default(false) bool isStreaming,
    @Default(false) bool isError,
    @Default(<ChatImageData>[]) List<ChatImageData> images,
    @Default(0) int createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

enum ChatMessageRole { user, assistant, system }
