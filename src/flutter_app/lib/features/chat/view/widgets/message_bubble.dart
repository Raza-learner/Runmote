import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/models/assistant_segment.dart';
import 'thinking_section.dart';
import 'tool_call_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == ChatMessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isUser
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: isUser
                          ? SelectableText(
                              message.content,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : SelectionArea(
                              child: SafeMarkdownBody(
                                data: message.content,
                                theme: theme,
                              ),
                            ),
                    ),
                ..._buildSegments(theme),
                if (message.isStreaming)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        _TypingDot(delay: 0),
                        _TypingDot(delay: 200),
                        _TypingDot(delay: 400),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
            child: Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSegments(ThemeData theme) {
    final result = <Widget>[];
    final toolCalls = <AssistantSegment>[];

    void flushTools() {
      if (toolCalls.isNotEmpty) {
        result.add(ToolCallGroup(
          key: ValueKey('tools_${toolCalls.first.id}'),
          segments: List.unmodifiable(toolCalls),
          isStreaming: message.isStreaming,
        ));
        toolCalls.clear();
      }
    }

    for (final seg in message.segments) {
      if (seg.kind == SegmentKind.toolCall) {
        toolCalls.add(seg);
      } else {
        flushTools();
        result.add(_buildSegment(seg, theme));
      }
    }
    flushTools();

    return result;
  }

  Widget _buildSegment(AssistantSegment seg, ThemeData theme) {
    switch (seg.kind) {
      case SegmentKind.thought:
        return ThinkingSection(
          key: ValueKey('thought_${seg.id}'),
          text: seg.text,
          isStreaming: message.isStreaming,
        );
      case SegmentKind.toolCall:
        // Tool calls are always grouped above; this branch is a fallback.
        final output = seg.metadata['output'] as String?;
        final isCompleted = seg.metadata['status'] == 'completed';
        final diffs = (seg.metadata['diffs'] as List<dynamic>?)
            ?.cast<Map<String, String>>();
        final terminalId = seg.metadata['terminalId'] as String?;
        return ToolCallCard(
          key: ValueKey('tool_${seg.id}'),
          name: seg.text,
          output: output,
          diffs: diffs,
          terminalId: terminalId,
          isCompleted: isCompleted,
          isStreaming: message.isStreaming,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

MarkdownStyleSheet _markdownStyle(ThemeData theme) {
  final cs = theme.colorScheme;
  return MarkdownStyleSheet(
    p: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.4),
    h1: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface,
    ),
    h2: TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface,
    ),
    h3: TextStyle(
      fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface,
    ),
    code: TextStyle(
      fontSize: 13, fontFamily: 'monospace', color: cs.onSurface,
      backgroundColor: cs.surfaceContainerHighest,
    ),
    codeblockDecoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: cs.primary, width: 3)),
      color: cs.surfaceContainerLow,
    ),
    listBullet: TextStyle(color: cs.onSurfaceVariant),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.outlineVariant)),
    ),
    strong: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
    em: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurface),
    a: TextStyle(color: cs.primary, decoration: TextDecoration.underline),
    blockSpacing: 8,
  );
}

class SafeMarkdownBody extends StatelessWidget {
  final String data;
  final ThemeData theme;

  const SafeMarkdownBody({super.key, required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    try {
      return MarkdownBody(
        data: data,
        styleSheet: _markdownStyle(theme),
        softLineBreak: true,
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(
              Uri.parse(href),
              mode: LaunchMode.externalApplication,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('[ACP-MD] markdown render error: $e');
      return SelectableText(
        data,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
        ),
      );
    }
  }
}

class ToolCallGroup extends StatefulWidget {
  final List<AssistantSegment> segments;
  final bool isStreaming;

  const ToolCallGroup({
    super.key,
    required this.segments,
    required this.isStreaming,
  });

  @override
  State<ToolCallGroup> createState() => _ToolCallGroupState();
}

class _ToolCallGroupState extends State<ToolCallGroup>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  Map<String, int> get _counts {
    final counts = <String, int>{};
    for (final seg in widget.segments) {
      final name = seg.text.split(' ').first.toLowerCase();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }

  bool get _allCompleted =>
      widget.segments.every((s) => s.metadata['status'] == 'completed');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = _counts;
    final anyRunning = widget.isStreaming && !_allCompleted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: counts.entries.map((e) {
                        return _ToolChip(
                          name: e.key,
                          count: e.value,
                        );
                      }).toList(),
                    ),
                  ),
                  if (anyRunning)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.segments.map((seg) {
                  final output = seg.metadata['output'] as String?;
                  final isCompleted = seg.metadata['status'] == 'completed';
                  final diffs = (seg.metadata['diffs'] as List<dynamic>?)
                      ?.cast<Map<String, String>>();
                  final terminalId = seg.metadata['terminalId'] as String?;
                  return ToolCallCard(
                    key: ValueKey(seg.id),
                    name: seg.text,
                    output: output,
                    diffs: diffs,
                    terminalId: terminalId,
                    isCompleted: isCompleted,
                    isStreaming: widget.isStreaming,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String name;
  final int count;

  const _ToolChip({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        count > 1 ? '$name ×$count' : name,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curved;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_curved);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 3),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
