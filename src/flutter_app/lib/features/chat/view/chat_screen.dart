import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/chat_provider.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/session_list_provider.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String cwd;

  const ChatScreen({super.key, required this.sessionId, required this.cwd});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollButton = false;
  bool _userScrolledUp = false;
  final List<Map<String, String>> _attachments = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pixels = _scrollController.position.pixels;
    final show = pixels > 160;
    final scrolledUp = pixels > 80;

    if (show != _showScrollButton) {
      setState(() => _showScrollButton = show);
    }
    _userScrolledUp = scrolledUp;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes ?? (await _readFile(file.path));
      if (bytes == null) return;
      final ext = file.extension?.toLowerCase() ?? 'jpg';
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      setState(() {
        _attachments.add({
          'name': file.name,
          'data': base64Encode(bytes),
          'mimeType': mime,
        });
      });
    } catch (e) {
      debugPrint('[ACP] file pick error: $e');
    }
  }

  Future<Uint8List?> _readFile(String? path) async {
    if (path == null) return null;
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    _textController.clear();

    List<Map<String, dynamic>>? extra;
    if (_attachments.isNotEmpty) {
      extra = _attachments.map((a) => <String, dynamic>{
            'type': 'image',
            'data': a['data'] ?? '',
            'mimeType': a['mimeType'] ?? 'image/jpeg',
          }).toList();
      setState(() => _attachments.clear());
    }

    ref
        .read(chatProvider((widget.sessionId, widget.cwd)).notifier)
        .sendMessage(text, extra: extra);
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    if (animate) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  void _scrollToBottomIfNearEnd() {
    if (!_scrollController.hasClients || _userScrolledUp) return;
    _scrollToBottom(animate: true);
  }

  String _sessionTitle(List<AcpSession> sessions) {
    final match = sessions.where((s) => s.id == widget.sessionId).firstOrNull;
    if (match?.title != null && match!.title!.isNotEmpty) {
      return match.title!;
    }
    if (widget.cwd.isNotEmpty && widget.cwd != '/') {
      final parts = widget.cwd.split('/');
      final last =
          parts.lastWhere((p) => p.isNotEmpty, orElse: () => widget.cwd);
      return last;
    }
    return 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider((widget.sessionId, widget.cwd)));
    final connection = ref.watch(connectionProvider);
    final sessionList = ref.watch(sessionListProvider);

    ref.listen(
      chatProvider((widget.sessionId, widget.cwd)),
      (previous, next) {
        final prevCount = previous?.valueOrNull?.messages.length ?? 0;
        final nextCount = next.valueOrNull?.messages.length ?? 0;
        final wasStreaming =
            previous?.valueOrNull?.messages.lastOrNull?.isStreaming ?? false;
        final isStreaming =
            next.valueOrNull?.messages.lastOrNull?.isStreaming ?? false;

        final newMessageArrived = nextCount > prevCount;
        final streamingStarted = isStreaming && !wasStreaming;
        if (newMessageArrived || streamingStarted) {
          Future.microtask(_scrollToBottomIfNearEnd);
        }
      },
    );

    final title = sessionList.whenOrNull(data: _sessionTitle) ??
        connection.agentInfo?.name ??
        'Chat';

    final isBusy = chatState.whenOrNull(data: (cs) => cs.isBusy) ?? false;
    final canSendImages = connection.capabilities?.canSendImages ?? false;

    final modelConfig = chatState.whenOrNull(
      data: (cs) => cs.configOptions
          .where((c) => c.category == 'model')
          .firstOrNull,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            if (connection.agentInfo?.name != null)
              Text(
                connection.agentInfo!.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 56,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load chat',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => ref
                            .read(chatProvider(
                                    (widget.sessionId, widget.cwd))
                                .notifier)
                            .loadMessages(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (cs) {
                final messages = cs.messages;
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a conversation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type a message below to begin chatting with the agent.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final reversedMessages = messages.reversed.toList();
                return Stack(
                  children: [
                    ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: reversedMessages.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      itemBuilder: (context, index) {
                        final msg = reversedMessages[index];
                        return RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: MessageBubble(message: msg),
                          ),
                        );
                      },
                    ),
                    if (_showScrollButton)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          onPressed: _scrollToBottom,
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(theme, isBusy, canSendImages, modelConfig),
        ],
      ),
    );
  }

  Widget _buildInputArea(
    ThemeData theme,
    bool isBusy,
    bool canSendImages,
    ConfigOption? modelConfig,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachments.isNotEmpty)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final att = _attachments[index];
                    return Chip(
                      label: Text(
                        att['name'] ?? 'file',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(
                          () => _attachments.removeAt(index)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                children: [
                  if (modelConfig != null)
                    _ModelChip(
                      label: modelConfig.currentValue.isNotEmpty
                          ? modelConfig.currentValue
                          : modelConfig.name,
                      onTap: () {
                        final cs = ref
                            .read(chatProvider(
                                (widget.sessionId, widget.cwd)))
                            .valueOrNull;
                        if (cs != null) _showConfigSheet(context, cs);
                      },
                    ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !isBusy,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: isBusy
                            ? 'Agent is responding...'
                            : 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (canSendImages && !isBusy)
                    IconButton(
                      onPressed: _pickFile,
                      icon: Icon(
                        Icons.attach_file,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Attach image',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  const SizedBox(width: 4),
                  isBusy
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : IconButton.filled(
                          onPressed:
                              _textController.text.trim().isNotEmpty ||
                                      _attachments.isNotEmpty
                                  ? _sendMessage
                                  : null,
                          icon: const Icon(Icons.arrow_upward),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigSheet(BuildContext context, ChatState cs) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...cs.configOptions.map((opt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.name,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Consumer(
                            builder: (ctx2, ref2, _) {
                              final live = ref2
                                  .watch(chatProvider((
                                          widget.sessionId, widget.cwd)))
                                  .valueOrNull;
                              final liveOpt = live?.configOptions
                                  .where((o) => o.id == opt.id)
                                  .firstOrNull;
                              final currentValue =
                                  liveOpt?.currentValue ?? opt.currentValue;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: opt.options.map((v) {
                                  final selected =
                                      v.value == currentValue;
                                  return ChoiceChip(
                                    label: Text(v.name),
                                    selected: selected,
                                    onSelected: (_) {
                                      ref2
                                          .read(chatProvider((
                                                  widget.sessionId,
                                                  widget.cwd))
                                              .notifier)
                                          .setConfigOption(
                                              opt.id, v.value);
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModelChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ModelChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer
                .withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                size: 13,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
