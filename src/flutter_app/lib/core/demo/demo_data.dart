import '../providers/connection_provider.dart';
import '../providers/session_list_provider.dart';
import '../models/chat_message.dart';
import '../models/assistant_segment.dart';
import '../../features/chat/viewmodel/chat_provider.dart';

final mockAgents = [
  const AcpAgent(id: 'opencode', name: 'opencode', version: '1.2.0', online: true),
  const AcpAgent(id: 'claude', name: 'claude code', version: '2.0.1', online: true),
  const AcpAgent(id: 'cursor', name: 'cursor', version: '0.8.5', online: true),
];

final mockSessions = [
  AcpSession(
    id: 'demo-1',
    title: 'Asking permission to access Apps directory',
    cwd: '/home/raza',
    updatedAt: DateTime.now().millisecondsSinceEpoch / 1000 - 5 * 24 * 3600,
    agentId: 'opencode',
  ),
  AcpSession(
    id: 'demo-2',
    title: 'Hyprland .conf to Lua migration',
    cwd: '/home/raza',
    updatedAt: DateTime.now().millisecondsSinceEpoch / 1000 - 14 * 24 * 3600,
    agentId: 'opencode',
  ),
];

final mockSlashCommands = [
  const SlashCommand(name: 'help', description: 'Show available commands', inputHint: '[command]'),
  const SlashCommand(name: 'fix', description: 'Fix failing tests', inputHint: '<file>'),
  const SlashCommand(name: 'review', description: 'Review last diff', inputHint: ''),
];

final mockMessagesDemo1 = [
  ChatMessage(
    id: 'demo-1-msg-1',
    role: ChatMessageRole.user,
    content: 'Asking permission to access Apps directory',
    createdAt: DateTime.now().millisecondsSinceEpoch - 30000,
  ),
  ChatMessage(
    id: 'demo-1-msg-2',
    role: ChatMessageRole.assistant,
    content: 'I\'ll check the Apps directory structure for you.',
    segments: [
      AssistantSegment(id: 'seg-thought-1', kind: SegmentKind.thought, text: 'User wants to explore /home/raza/Apps. Need to verify permissions and list contents. Check if directory exists, count apps, prepare response.'),
      AssistantSegment(id: 'seg-tool-1', kind: SegmentKind.toolCall, text: 'read_directory /home/raza/Apps'),
    ],
    createdAt: DateTime.now().millisecondsSinceEpoch - 25000,
  ),
  ChatMessage(
    id: 'demo-1-msg-3',
    role: ChatMessageRole.assistant,
    content: 'Found 12 applications in /home/raza/Apps:\n- calculator, notes, browser\n- media-player, editor\nAll accessible. Permission granted ✓',
    createdAt: DateTime.now().millisecondsSinceEpoch - 20000,
  ),
];

final mockMessagesDemo2 = [
  ChatMessage(
    id: 'demo-2-msg-1',
    role: ChatMessageRole.user,
    content: 'Hyprland .conf to Lua migration',
    createdAt: DateTime.now().millisecondsSinceEpoch - 40000,
  ),
  ChatMessage(
    id: 'demo-2-msg-2',
    role: ChatMessageRole.assistant,
    content: 'Starting migration from Hyprland .conf to Lua...',
    segments: [
      AssistantSegment(id: 'seg-thought-2', kind: SegmentKind.thought, text: 'Hyprland now supports Lua config for better performance. Need to parse existing .conf, convert bindings and window rules to Lua syntax, preserve comments.'),
      AssistantSegment(id: 'seg-tool-2', kind: SegmentKind.toolCall, text: 'read_file: ~/.config/hypr/hyprland.conf'),
    ],
    createdAt: DateTime.now().millisecondsSinceEpoch - 35000,
  ),
  ChatMessage(
    id: 'demo-2-msg-3',
    role: ChatMessageRole.assistant,
    content: 'Migration complete! Converted 47 lines of config.',
    segments: [
      AssistantSegment(
        id: 'seg-diff-1',
        kind: SegmentKind.toolCall,
        text: 'write_file: ~/.config/hypr/hyprland.lua',
        metadata: {
          'diffs': [
            {
              'oldText': 'bind=SUPER,Return,exec,kitty\nwindowrulev2 = float,class:^(pavucontrol)\$',
              'newText': 'bind("SUPER", "Return", "exec, kitty")\nwindow_rule("float", "class:^(pavucontrol)\$")',
              'path': '~/.config/hypr/hyprland.conf → hyprland.lua',
            }
          ]
        },
      ),
    ],
    createdAt: DateTime.now().millisecondsSinceEpoch - 30000,
  ),
];
