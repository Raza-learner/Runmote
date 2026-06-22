import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_command.freezed.dart';
part 'chat_command.g.dart';

@freezed
class ChatCommand with _$ChatCommand {
  const factory ChatCommand({
    required String name,
    String? description,
  }) = _ChatCommand;

  factory ChatCommand.fromJson(Map<String, dynamic> json) =>
      _$ChatCommandFromJson(json);
}
