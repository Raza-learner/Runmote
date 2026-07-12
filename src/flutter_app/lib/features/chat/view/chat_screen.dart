import 'dart:ui' as ui;

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
import '../../../shared/widgets/daemon_offline_banner.dart';
import '../../../shared/widgets/animated_background.dart';
import 'widgets/chat_skeleton.dart';
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
  late String _title;
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    _title = _fallbackTitle(widget.cwd);
    _scrollController.addListener(_onScroll);
    _textController.addListener(() => setState(() {}));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  String _fallbackTitle(String cwd) {
    if (cwd.isNotEmpty && cwd != '/') {
      final parts = cwd.split('/');
      return parts.lastWhere((p) => p.isNotEmpty, orElse: () => cwd);
    }
    return 'Chat';
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
      debugPrint('[RUNMOTE] file pick error: $e');
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
    final connection = ref.watch(connectionProvider);
    final canSendImages = connection.capabilities?.canSendImages ?? false;
    final daemonDown = connection.paired && !connection.daemonConnected;

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

        final prevReq = previous?.valueOrNull?.permissionRequest;
        final nextReq = next.valueOrNull?.permissionRequest;
        if (nextReq != null && prevReq != nextReq) {
          Future.microtask(() {
            if (mounted) _showPermissionDialog(context, nextReq);
          });
        }
      },
    );

    ref.listen(
      sessionListProvider,
      (previous, next) {
        final sessions = next.valueOrNull;
        if (sessions == null) return;
        final newTitle = _sessionTitle(sessions);
        if (newTitle.isNotEmpty && newTitle != _title) {
          setState(() => _title = newTitle);
        }
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.1),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close session',
            onPressed: () {
              ref.read(connectionProvider.notifier).closeSession(widget.sessionId);
              context.pop();
            },
          ),
        ],
      ),
      body: AnimatedBackground(
        showGrid: false,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 8),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final chatState = ref.watch(
                    chatProvider((widget.sessionId, widget.cwd)),
                  );
                  if (_showSkeleton || chatState.isLoading) {
                    return Column(
                      children: [
                        if (daemonDown) const DaemonOfflineBanner(),
                        const Expanded(child: ChatSkeleton()),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      if (daemonDown) const DaemonOfflineBanner(),
                      Consumer(
                        builder: (context, ref, child) {
                          final modeOptions = ref.watch(
                            chatProvider((widget.sessionId, widget.cwd)).select(
                              (state) => state.valueOrNull?.configOptions
                                      .where((c) => c.category == 'mode')
                                      .toList() ??
                                  [],
                            ),
                          );
                          if (modeOptions.isEmpty || modeOptions.first.options.length <= 1) {
                            return const SizedBox.shrink();
                          }
                          return _buildModeSelector(theme, modeOptions.first);
                        },
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: chatState.whenOrNull(
                                  data: (cs) {
                                  final messages = cs.messages;
                                  if (messages.isEmpty) {
                                    final t = Theme.of(context);
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 48),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: t.brightness == Brightness.dark 
                                                    ? Colors.white.withValues(alpha: 0.05)
                                                    : Colors.black.withValues(alpha: 0.03),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.chat_bubble_outline_rounded,
                                                size: 64,
                                                color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              'Ready to help',
                                              style: t.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Type a message below to start your conversation with the agent.',
                                              style: t.textTheme.bodyMedium?.copyWith(
                                                color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  final reversedMessages = messages.reversed.toList();
                                  return ListView.builder(
                                    reverse: true,
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: reversedMessages.length,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    itemBuilder: (context, index) {
                                      final msg = reversedMessages[index];
                                      return RepaintBoundary(
                                        key: ValueKey(msg.id),
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: MessageBubble(message: msg),
                                        ),
                                      );
                                    },
                                  );
                                },
                                error: (e, _) {
                                  final t = Theme.of(context);
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 56,
                                            color: t.colorScheme.error,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Could not load chat',
                                            style: t.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            e.toString(),
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.bodyMedium?.copyWith(
                                              color: t.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          FilledButton.tonal(
                                            onPressed: () => ref
                                                .read(chatProvider((
                                                        widget.sessionId, widget.cwd))
                                                    .notifier)
                                                .loadMessages(),
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ) ?? const Center(child: Text('Could not load chat')),
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildInputArea(theme, canSendImages, daemonDown),
          ],
        ),
      ),
    );
  }

  List<SlashCommand> _filterSlashCommands(List<SlashCommand> commands, String query) {
    if (query.isEmpty) return commands;
    final q = query.toLowerCase();
    return commands.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Widget _buildInputArea(ThemeData theme, bool canSendImages, bool daemonDown) {
    final text = _textController.text;
    final isDark = theme.brightness == Brightness.dark;
    final slashMatch = text.startsWith('/') ? text.substring(1) : null;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? theme.colorScheme.surface.withValues(alpha: 0.1)
                : theme.colorScheme.surface.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Consumer(
          builder: (context, ref, child) {
            final chatState =
                ref.watch(chatProvider((widget.sessionId, widget.cwd)));
            final cs = chatState.valueOrNull;
            final isBusy = cs?.isBusy ?? false;

            final slashCommands = slashMatch != null && cs != null
                ? _filterSlashCommands(cs.availableCommands, slashMatch)
                : <SlashCommand>[];
            final modelConfig = cs?.configOptions
                .where((c) => c.category == 'model')
                .firstOrNull;
            final modelLabel = modelConfig != null
                ? (modelConfig.currentValue.isNotEmpty
                    ? modelConfig.currentValue
                    : modelConfig.name.isNotEmpty
                        ? modelConfig.name
                        : null)
                : (cs?.currentModel?.isNotEmpty ?? false)
                    ? cs!.currentModel
                    : ref.read(connectionProvider).agentInfo?.name;
            final t = Theme.of(context);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_attachments.isNotEmpty)
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachments.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final att = _attachments[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: t.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: t.colorScheme.outlineVariant),
                          ),
                          padding: const EdgeInsets.only(left: 10, right: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: 16, color: t.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                att['name'] ?? 'file',
                                style: t.textTheme.labelMedium,
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _attachments.removeAt(index)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (slashCommands.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    decoration: BoxDecoration(
                      color: t.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: slashCommands.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: t.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        padding: EdgeInsets.zero,
                        itemBuilder: (ctx, i) {
                          final cmd = slashCommands[i];
                          final hint = cmd.inputHint != null ? ' ${cmd.inputHint}' : '';
                          return InkWell(
                            onTap: () {
                              _textController.text = '/${cmd.name} ';
                              _textController.selection = TextSelection.collapsed(
                                offset: _textController.text.length,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '/${cmd.name}',
                                    style: t.textTheme.labelLarge?.copyWith(
                                      color: t.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${cmd.description}$hint',
                                      style: t.textTheme.bodyMedium?.copyWith(
                                        color: t.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                  child: Row(
                    children: [
                      if (modelLabel != null)
                        _ModelChip(
                          label: modelLabel,
                          onTap: (cs != null && cs.configOptions.isNotEmpty)
                              ? () => _showConfigSheet(context, cs)
                              : null,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (canSendImages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: IconButton(
                            onPressed: (isBusy || daemonDown) ? null : _pickFile,
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: t.colorScheme.primary,
                            ),
                            tooltip: 'Attach image',
                          ),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          readOnly: isBusy || daemonDown,
                          minLines: 1,
                          maxLines: 6,
                          style: t.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: daemonDown
                                ? 'Daemon not connected'
                                : isBusy
                                    ? 'Agent is responding...'
                                    : 'Message...',
                            hintStyle: t.textTheme.bodyLarge?.copyWith(
                              color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: t.colorScheme.surfaceContainerHigh,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: isBusy
                              ? Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: t.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : IconButton.filled(
                                  onPressed: daemonDown ||
                                          (_textController.text.trim().isEmpty &&
                                              _attachments.isEmpty)
                                      ? null
                                      : _sendMessage,
                                  icon: const Icon(Icons.arrow_upward, size: 24),
                                  style: IconButton.styleFrom(
                                    backgroundColor: t.colorScheme.primary,
                                    foregroundColor: t.colorScheme.onPrimary,
                                    disabledBackgroundColor: t.colorScheme.surfaceContainerHighest,
                                    disabledForegroundColor: t.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(
    ThemeData theme,
    ConfigOption opt,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: opt.options.map((v) {
            final selected = v.value == opt.currentValue;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(v.name, style: const TextStyle(fontSize: 12)),
                selected: selected,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  ref
                      .read(chatProvider(
                              (widget.sessionId, widget.cwd))
                          .notifier)
                      .setConfigOption(opt.id, v.value);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, PermissionRequest req) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                req.title ?? 'Permission Requested',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (req.toolName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        req.toolName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (req.toolContent.isNotEmpty)
              ...req.toolContent.map((c) {
                final text = c['text'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    text,
                    style: theme.textTheme.bodySmall,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            const SizedBox(height: 12),
            Text(
              'Allow the agent to perform this action?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(chatProvider(
                          (widget.sessionId, widget.cwd))
                      .notifier)
                  .dismissPermission();
            },
            child: const Text('Cancel'),
          ),
          ...req.options.map((opt) {
            final isAllow = opt.kind.contains('allow');
            return isAllow
                ? FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ref
                          .read(chatProvider(
                                  (widget.sessionId, widget.cwd))
                              .notifier)
                          .respondToPermission(opt.optionId);
                    },
                    child: Text(opt.name),
                  )
                : TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ref
                          .read(chatProvider(
                                  (widget.sessionId, widget.cwd))
                              .notifier)
                          .respondToPermission(opt.optionId);
                    },
                    child: Text(opt.name),
                  );
          }),
        ],
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
  final VoidCallback? onTap;

  const _ModelChip({required this.label, this.onTap});

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
