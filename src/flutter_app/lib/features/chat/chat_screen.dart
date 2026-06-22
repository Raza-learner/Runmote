import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/assistant_segment.dart';
import '../../core/models/tool_call_display.dart';
import '../../core/models/plan_entry.dart';
import '../../core/models/connection_state.dart';
import '../../core/providers/connection_provider.dart';
import '../../core/providers/active_session_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String title;

  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.title,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ref.read(activeSessionProvider.notifier).state = widget.sessionId;
  }

  @override
  void dispose() {
    final current = ref.read(activeSessionProvider);
    if (current == widget.sessionId) {
      ref.read(activeSessionProvider.notifier).state = null;
    }
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.sessionId));
    final connectionState = ref.watch(connectionProvider);
    final theme = Theme.of(context);

    final isConnected = connectionState is Connected;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Chat title: ${widget.title}',
              child: Text(widget.title),
            ),
            _ConnectionStatusChip(state: connectionState),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isConnected && messages.isNotEmpty)
            Semantics(
              label: 'Connection issue banner',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: theme.colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, size: 14, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        connectionState.when(
                          disconnected: () => 'Disconnected. Reconnecting...',
                          connecting: () => 'Connecting...',
                          connected: () => '',
                          reconnecting: () => 'Reconnecting...',
                          failed: (e) => 'Connection failed${e != null ? ': $e' : ''}',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(connectionProvider.notifier).reconnect(),
                      child: Text('Retry', style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      )),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: messages.isEmpty
                ? Semantics(
                    label: 'No messages yet',
                    child: EmptyStateWidget(
                      icon: Icons.chat_bubble_outline,
                      title: 'Start a conversation',
                      subtitle: 'Send a message to begin',
                    ),
                  )
                : Semantics(
                    label: 'Chat messages',
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _AnimatedMessage(
                        index: index,
                        child: _MessageBubble(message: msg, theme: theme, sessionId: widget.sessionId, onRemove: () {
                          _deleteMessage(index);
                        }),
                      );
                      },
                    ),
                  ),
          ),
          _buildInputBar(theme, isConnected),
        ],
      ),
    );
  }

  void _deleteMessage(int index) {
    HapticFeedback.lightImpact();
    ref.read(chatProvider(widget.sessionId).notifier).removeMessageAt(index);
  }

  Widget _buildInputBar(ThemeData theme, bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Semantics(
                label: 'Attach file',
                child: IconButton(
                  icon: Icon(Icons.attach_file, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => _pickAndSendFile(),
                ),
              ),
              Expanded(
                child: Semantics(
                  label: 'Message input field',
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: isConnected ? 'Type a message...' : 'Waiting for connection...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    maxLines: 5,
                    minLines: 1,
                    onSubmitted: _handleSend,
                    enabled: isConnected,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Send message',
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, _) {
                    final hasText = _textController.text.trim().isNotEmpty;
                    return IconButton(
                      icon: Icon(
                        hasText ? Icons.send_rounded : Icons.mic_none,
                        color: hasText
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: (isConnected && hasText)
                          ? () => _handleSend(_textController.text)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndSendFile() async {
    HapticFeedback.selectionClick();
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final mimeType = _mimeFromExtension(file.extension ?? '') ?? 'application/octet-stream';
      ref.read(connectionProvider.notifier).sendFileUpload(
        sessionId: widget.sessionId,
        fileName: file.name,
        fileData: base64Data,
        mimeType: mimeType,
      );
      final msg = ChatMessage(
        id: const Uuid().v4(),
        role: ChatMessageRole.user,
        content: '[Attached: ${file.name}]',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      ref.read(chatProvider(widget.sessionId).notifier).addLocalMessage(msg);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach file: $e')),
        );
      }
    }
  }

  String? _mimeFromExtension(String ext) {
    final e = ext.toLowerCase();
    if (['yaml', 'yml'].contains(e)) return 'text/yaml';
    if (['html', 'htm'].contains(e)) return 'text/html';
    if (['sh', 'bash', 'zsh'].contains(e)) return 'text/x-shellscript';
    if (['jpg', 'jpeg'].contains(e)) return 'image/jpeg';
    if (['tar', 'gz'].contains(e)) return 'application/gzip';
    return switch (e) {
      'txt' => 'text/plain',
      'md' => 'text/markdown',
      'json' => 'application/json',
      'js' => 'application/javascript',
      'py' => 'text/x-python',
      'dart' => 'text/x-dart',
      'toml' => 'text/toml',
      'xml' => 'application/xml',
      'css' => 'text/css',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'svg' => 'image/svg+xml',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'zip' => 'application/zip',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'mp4' => 'video/mp4',
      _ => null,
    };
  }

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.mediumImpact();
    _textController.clear();
    ref.read(chatProvider(widget.sessionId).notifier).sendMessage(trimmed);
    _focusNode.requestFocus();
    _scrollToBottom();
  }
}

class _ConnectionStatusChip extends StatelessWidget {
  final AcpConnectionState state;

  const _ConnectionStatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      Disconnected() => Colors.grey,
      Connecting() => Colors.orange,
      Connected() => Colors.green,
      Reconnecting() => Colors.red,
      Failed() => Colors.red,
    };
    final label = state.when(
      disconnected: () => 'Disconnected',
      connecting: () => 'Connecting...',
      connected: () => 'Connected',
      reconnecting: () => 'Reconnecting...',
      failed: (e) => 'Failed${e != null ? ': $e' : ''}',
    );

    return Semantics(
      label: 'Connection status: $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedMessage({required this.index, required this.child});

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(curve);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  final VoidCallback? onRemove;
  final String sessionId;

  const _MessageBubble({
    required this.message,
    required this.theme,
    this.onRemove,
    this.sessionId = '',
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;

    return Semantics(
      label: '${isUser ? "User" : "Assistant"} message${message.isError ? ", error" : ""}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Semantics(
                label: 'Assistant avatar',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.smart_toy, size: 18, color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.segments.isNotEmpty && !isUser)
                    ...message.segments.map((seg) => _SegmentWidget(
                      segment: seg,
                      theme: theme,
                      sessionId: sessionId,
                    )),
                  if (message.content.isNotEmpty || (message.segments.isEmpty && !isUser))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isError
                            ? theme.colorScheme.errorContainer
                            : isUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(18),
                          bottomRight: isUser ? const Radius.circular(18) : const Radius.circular(18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: message.isError
                                  ? theme.colorScheme.onErrorContainer
                                  : isUser
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (message.isStreaming)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Semantics(
                                label: 'Assistant is typing',
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isUser
                                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              Semantics(
                label: 'User avatar',
                child: GestureDetector(
                  onLongPress: onRemove,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person, size: 18, color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentWidget extends StatelessWidget {
  final AssistantSegment segment;
  final ThemeData theme;
  final String sessionId;

  const _SegmentWidget({required this.segment, required this.theme, this.sessionId = ''});

  @override
  Widget build(BuildContext context) {
    switch (segment.kind) {
      case AssistantSegmentKind.thought:
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Thought',
                child: Icon(Icons.psychology, size: 16, color: theme.colorScheme.tertiary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Semantics(
                  label: 'Thought content',
                  child: Text(
                    segment.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case AssistantSegmentKind.toolCall:
        final tc = segment.toolCall;
        if (tc == null) return const SizedBox.shrink();
        return _ToolCallCard(toolCall: tc, theme: theme, sessionId: sessionId);
      case AssistantSegmentKind.plan:
        if (segment.planEntries.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Plan',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Plan', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              ...segment.planEntries.map((entry) => Semantics(
                label: 'Plan entry: ${entry.status.name}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        entry.status == PlanEntryStatus.completed
                            ? Icons.check_circle
                            : entry.status == PlanEntryStatus.inProgress
                                ? Icons.play_circle
                                : Icons.radio_button_unchecked,
                        size: 14,
                        color: entry.status == PlanEntryStatus.completed
                            ? Colors.green
                            : entry.status == PlanEntryStatus.inProgress
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.content,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: entry.status == PlanEntryStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: entry.status == PlanEntryStatus.completed
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 4),
            ],
          ),
        );
      case AssistantSegmentKind.message:
        return Semantics(
          label: 'Message segment',
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              segment.text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
    }
  }
}

class _ToolCallCard extends StatefulWidget {
  final ToolCallDisplay toolCall;
  final ThemeData theme;
  final String sessionId;

  const _ToolCallCard({required this.toolCall, required this.theme, this.sessionId = ''});

  @override
  State<_ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<_ToolCallCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tc = widget.toolCall;
    final theme = widget.theme;
    final hasPermission = tc.permissionOptions.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Semantics(
                  label: 'Tool kind: ${tc.kind?.name ?? "tool"}',
                  child: Icon(
                    _toolIcon(tc.kind),
                    size: 14,
                    color: _toolStatusColor(tc.status, theme),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tc.title.isNotEmpty ? tc.title : (tc.kind?.name ?? 'Tool call'),
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (tc.status != null)
                  Semantics(
                    label: 'Status: ${tc.status!.name}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _toolStatusBgColor(tc.status!, theme),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel(tc.status!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _toolStatusColor(tc.status!, theme),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                if (tc.rawInput != null || tc.rawOutput != null)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (hasPermission) ...[
            const SizedBox(height: 8),
            _buildPermissionOptions(theme),
          ],
          if (_expanded) ...[
            if (tc.rawInput != null && tc.rawInput!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Semantics(
                label: 'Tool input',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tc.rawInput!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            if (tc.rawOutput != null && tc.rawOutput!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildContent(theme),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionOptions(ThemeData theme) {
    final permissionRequestId = widget.toolCall.permissionRequestId ?? '';
    return Semantics(
      label: 'Permission request',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, size: 14, color: theme.colorScheme.tertiary),
                const SizedBox(width: 4),
                Text('Permission Required', style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                )),
              ],
            ),
            const SizedBox(height: 4),
            ...widget.toolCall.permissionOptions.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 6, color: theme.colorScheme.onTertiaryContainer),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${opt.label} (${opt.kind})',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer(builder: (context, ref, _) {
                  return Semantics(
                    label: 'Deny permission',
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(connectionProvider.notifier).sendPermissionResponse(
                          sessionId: widget.sessionId,
                          permissionRequestId: permissionRequestId,
                          approved: false,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Deny', style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      )),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Consumer(builder: (context, ref, _) {
                  return Semantics(
                    label: 'Approve permission',
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(connectionProvider.notifier).sendPermissionResponse(
                          sessionId: widget.sessionId,
                          permissionRequestId: permissionRequestId,
                          approved: true,
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Approve', style: theme.textTheme.labelSmall),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final tc = widget.toolCall;
    if (tc.content.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tc.rawOutput!,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            fontSize: 10,
          ),
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tc.content.map((c) {
        return c.when(
          text: (text) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ),
          image: (data, mimeType) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(mimeType, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9)),
                  ],
                ),
              ),
            ),
          ),
          audio: (mimeType) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.audiotrack, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(mimeType, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9)),
                ],
              ),
            ),
          ),
          resourceLink: (name, uri, description) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 14, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        )),
                        Text(uri, style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(Icons.download, size: 14, color: theme.colorScheme.secondary),
                ],
              ),
            ),
          ),
          resource: (uri, text) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text != null && text.isNotEmpty)
                    Text(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 9,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    uri,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 8,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          terminal: (terminalId) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terminal, size: 14, color: Colors.greenAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          terminalId,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      _TerminalCursor(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$ echo "ready"',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _toolIcon(ToolKind? kind) {
    return switch (kind) {
      ToolKind.read => Icons.description,
      ToolKind.edit => Icons.edit,
      ToolKind.delete => Icons.delete,
      ToolKind.move => Icons.drive_file_move,
      ToolKind.search => Icons.search,
      ToolKind.execute => Icons.terminal,
      ToolKind.think => Icons.psychology,
      ToolKind.fetch => Icons.cloud_download,
      ToolKind.switchMode => Icons.swap_horiz,
      ToolKind.other => Icons.code,
      null => Icons.code,
    };
  }

  Color _toolStatusColor(ToolCallStatus? status, ThemeData theme) {
    return switch (status) {
      ToolCallStatus.pending => theme.colorScheme.onSurfaceVariant,
      ToolCallStatus.inProgress => Colors.orange,
      ToolCallStatus.completed => Colors.green,
      ToolCallStatus.failed => Colors.red,
      null => theme.colorScheme.onSurfaceVariant,
    };
  }

  Color _toolStatusBgColor(ToolCallStatus status, ThemeData theme) {
    return _toolStatusColor(status, theme).withValues(alpha: 0.15);
  }

  String _statusLabel(ToolCallStatus status) {
    return switch (status) {
      ToolCallStatus.pending => 'pending',
      ToolCallStatus.inProgress => 'running',
      ToolCallStatus.completed => 'done',
      ToolCallStatus.failed => 'failed',
    };
  }
}

class _TerminalCursor extends StatefulWidget {
  @override
  State<_TerminalCursor> createState() => _TerminalCursorState();
}

class _TerminalCursorState extends State<_TerminalCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 12,
        color: Colors.greenAccent,
      ),
    );
  }
}
