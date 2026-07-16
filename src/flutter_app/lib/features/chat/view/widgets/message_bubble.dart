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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _MessageAvatar(isUser: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.05)
                            : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: !isUser && theme.brightness == Brightness.dark
                        ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.content.isNotEmpty)
                        isUser
                            ? Text(
                                message.content,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onPrimary,
                                  height: 1.4,
                                ),
                              )
                            : SelectionArea(
                                child: SafeMarkdownBody(
                                  data: message.content,
                                  theme: theme,
                                ),
                              ),
                      if (message.segments.isNotEmpty && !isUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildSegments(theme),
                          ),
                        ),
                      if (message.isStreaming && !isUser)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 2),
                          child: _StreamingIndicator(),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _MessageAvatar(isUser: true),
          ],
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
    p: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.5, letterSpacing: 0.1),
    h1: TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    h2: TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    h3: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    code: TextStyle(
      fontSize: 13,
      fontFamily: 'monospace',
      color: cs.onSecondaryContainer,
      backgroundColor: cs.secondaryContainer.withValues(alpha: 0.5),
    ),
    codeblockDecoration: BoxDecoration(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
    ),
    codeblockPadding: const EdgeInsets.all(16),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: cs.primary, width: 4)),
      color: cs.surfaceContainerLow,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
    ),
    listBullet: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.outlineVariant, width: 1)),
    ),
    strong: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
    em: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurface),
    a: TextStyle(
      color: cs.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w500,
    ),
    blockSpacing: 12,
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
    final isDark = theme.brightness == Brightness.dark;
    final counts = _counts;
    final anyRunning = widget.isStreaming && !_allCompleted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.02)
            : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.blue.withValues(alpha: 0.1)
                          : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_input_component,
                      size: 14,
                      color: isDark ? Colors.blue.shade300 : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Executing Tools',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: counts.entries.map((e) {
                            return Text(
                              e.value > 1 ? '${e.key} (${e.value})' : e.key,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
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

class _MessageAvatar extends StatelessWidget {
  final bool isUser;

  const _MessageAvatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: isUser
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onTertiaryContainer,
      ),
    );
  }
}

class _StreamingIndicator extends StatelessWidget {
  const _StreamingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Agent is typing...',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
