import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_call_content.freezed.dart';
part 'tool_call_content.g.dart';

@freezed
sealed class ToolCallContent with _$ToolCallContent {
  const factory ToolCallContent.text(String text) = TextContent;
  const factory ToolCallContent.image({
    required String data,
    required String mimeType,
  }) = ImageContent;
  const factory ToolCallContent.audio(String mimeType) = AudioContent;
  const factory ToolCallContent.resourceLink({
    required String name,
    required String uri,
    String? description,
  }) = ResourceLinkContent;
  const factory ToolCallContent.resource({required String uri, String? text}) =
      ResourceContent;
  const factory ToolCallContent.terminal(String terminalId) = TerminalContent;

  factory ToolCallContent.fromJson(Map<String, dynamic> json) =>
      _$ToolCallContentFromJson(json);
}
