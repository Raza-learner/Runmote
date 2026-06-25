import 'package:flutter/material.dart';

import '../../core/models/chat_message.dart';
import '../../core/models/assistant_segment.dart';
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
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ..._buildSegments(theme),
                if (message.isStreaming)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
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
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
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
        return ThinkingSection(text: seg.text, isStreaming: message.isStreaming);
      case SegmentKind.toolCall:
        // Tool calls are always grouped above; this branch is a fallback.
        final output = seg.metadata['output'] as String?;
        final isCompleted = seg.metadata['status'] == 'completed';
        return ToolCallCard(
          name: seg.text,
          output: output,
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
                  return ToolCallCard(
                    name: seg.text,
                    output: output,
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
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
