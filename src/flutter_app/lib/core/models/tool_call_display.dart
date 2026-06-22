import 'package:freezed_annotation/freezed_annotation.dart';
import 'tool_call_content.dart';
import 'permission_option.dart';

part 'tool_call_display.freezed.dart';
part 'tool_call_display.g.dart';

@freezed
class ToolCallDisplay with _$ToolCallDisplay {
  const factory ToolCallDisplay({
    String? toolCallId,
    @Default('') String title,
    ToolKind? kind,
    ToolCallStatus? status,
    @Default(<ToolCallContent>[]) List<ToolCallContent> content,
    String? rawInput,
    String? rawOutput,
    @Default(<PermissionOption>[]) List<PermissionOption> permissionOptions,
    String? permissionRequestId,
  }) = _ToolCallDisplay;

  factory ToolCallDisplay.fromJson(Map<String, dynamic> json) =>
      _$ToolCallDisplayFromJson(json);
}

enum ToolKind {
  read,
  edit,
  delete,
  move,
  search,
  execute,
  think,
  fetch,
  switchMode,
  other,
}

enum ToolCallStatus { pending, inProgress, completed, failed }
