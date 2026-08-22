import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
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

    // User: compact bubble on the right (like iMessage).
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      _formatTime(message.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _MessageAvatar(isUser: true),
          ],
        ),
      );
    }

    // Assistant: full-screen plain text (ChatGPT/Claude style) — no bubble,
    // spans available width for readable markdown, tables, and code.
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.content.isNotEmpty)
            SelectionArea(
              child: SafeMarkdownBody(
                data: message.content,
                theme: theme,
              ),
            ),
          if (message.segments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSegments(theme),
              ),
            ),
          if (message.isStreaming)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(
              _formatTime(message.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
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
  final isDark = theme.brightness == Brightness.dark;
  return MarkdownStyleSheet(
    p: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.6, letterSpacing: 0.1),
    pPadding: const EdgeInsets.only(bottom: 8),
    h1: TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
    h2: TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
    h3: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.3,
    ),
    h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
    code: TextStyle(
      fontSize: 13,
      fontFamily: 'monospace',
      color: isDark ? Colors.white.withValues(alpha: 0.9) : cs.onSurface,
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : cs.surfaceContainerHighest.withValues(alpha: 0.9),
      height: 1.4,
    ),
    codeblockPadding: const EdgeInsets.all(14),
    codeblockDecoration: BoxDecoration(
      color: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : cs.surfaceContainerHighest.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
    ),
    blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: cs.primary, width: 3)),
      color: isDark ? Colors.white.withValues(alpha: 0.04) : cs.surfaceContainerLow,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
    ),
    listBullet: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 15),
    listIndent: 20,
    listBulletPadding: const EdgeInsets.only(right: 8),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1)),
    ),
    strong: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
    em: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurface),
    a: TextStyle(
      color: cs.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w500,
    ),
    blockSpacing: 10,
    tableHead: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: cs.onSurface),
    tableBody: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
    tableHeadAlign: TextAlign.left,
    tableBorder: TableBorder.all(
      color: cs.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.3),
      width: 1,
      borderRadius: BorderRadius.circular(8),
    ),
    tableColumnWidth: const FlexColumnWidth(),
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    tableCellsDecoration: BoxDecoration(
      color: Colors.transparent,
    ),
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
      // Detect if data contains a markdown table before building, and wrap
      // with a horizontal scroll when needed. flutter_markdown 0.7.7 renders
      // tables with FlexColumnWidth and no scroll — wide tables overflow
      // and look squished on phones. We detect pipe tables and provide a
      // scroll wrapper via a custom builder.
      final hasTable = _looksLikeTable(data);
      final sheet = _markdownStyle(theme);
      final cs = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      // For messages with tables, render inside a horizontal scroll wrapper
      // via a custom table builder. For non-table messages, use default.
      if (hasTable) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SelectionArea(
              child: MarkdownBody(
                data: data,
                styleSheet: sheet.copyWith(
                  tableColumnWidth: const IntrinsicColumnWidth(),
                  tableBorder: TableBorder.all(
                    color: cs.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.3),
                    width: 1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                extensionSet: md.ExtensionSet.gitHubFlavored,
                softLineBreak: true,
                builders: {
                  'table': _TableScrollBuilder(theme),
                },
                onTapLink: (text, href, title) {
                  if (href != null) {
                    launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                  }
                },
                selectable: false,
              ),
            );
          },
        );
      }

      return SelectionArea(
        child: MarkdownBody(
          data: data,
          styleSheet: sheet,
          extensionSet: md.ExtensionSet.gitHubFlavored,
          softLineBreak: true,
          selectable: false,
          onTapLink: (text, href, title) {
            if (href != null) {
              launchUrl(
                Uri.parse(href),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('[ACP-MD] markdown render error: $e');
      return SelectableText(
        data,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      );
    }
  }

  bool _looksLikeTable(String s) {
    // Simple heuristic: a markdown pipe table has at least one line with '|' and
    // a following separator line with '|', ':', '-', or spaces.
    final lines = s.split('\n');
    for (var i = 0; i < lines.length - 1; i++) {
      final a = lines[i];
      final b = lines[i + 1];
      if (a.contains('|') && b.contains('|') && RegExp(r'^\s*\|?[\s:|-\|]+\|?\s*$').hasMatch(b)) {
        return true;
      }
    }
    // Fallback: any pipe-heavy line
    return false;
  }
}

/// Wraps a markdown table in a horizontal scroll so wide tables don't overflow
/// the bubble on phones. Keeps default table styling but makes columns
/// intrinsic and scrollable — matching the fix in flutter/packages#8526.
class _TableScrollBuilder extends MarkdownElementBuilder {
  final ThemeData theme;
  _TableScrollBuilder(this.theme);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // This is called for the 'table' element. Its children are thead/tbody.
    // We need to collect all <tr> rows and build a Table ourselves, then wrap
    // it in a scroll view. If anything fails, return null to fallback.
    try {
      final rows = <TableRow>[];
      bool isFirstRow = true;

      void addRowsFromSection(md.Element section) {
        for (final child in section.children ?? []) {
          if (child is md.Element && child.tag == 'tr') {
            rows.add(_buildRow(child, isFirstRow));
            isFirstRow = false;
          }
        }
      }

      for (final child in element.children ?? []) {
        if (child is md.Element) {
          if (child.tag == 'thead' || child.tag == 'tbody') {
            addRowsFromSection(child);
          } else if (child.tag == 'tr') {
            rows.add(_buildRow(child, isFirstRow));
            isFirstRow = false;
          }
        }
      }

      if (rows.isEmpty) return null;

      final cs = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      final table = Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.28),
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        children: rows,
      );

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
      );
    } catch (e) {
      debugPrint('[MD-table] builder error: $e');
      return null;
    }
  }

  TableRow _buildRow(md.Element tr, bool isHeader) {
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cells = <Widget>[];

    for (final cell in tr.children ?? []) {
      if (cell is md.Element && (cell.tag == 'th' || cell.tag == 'td')) {
        final align = cell.attributes['align'];
        TextAlign textAlign;
        switch (align) {
          case 'center':
            textAlign = TextAlign.center;
            break;
          case 'right':
            textAlign = TextAlign.right;
            break;
          default:
            textAlign = TextAlign.left;
        }

        final cellText = _extractCellText(cell);
        final isTh = cell.tag == 'th' || isHeader && tr.children!.first == cell;

        cells.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            constraints: const BoxConstraints(minWidth: 80, maxWidth: 220),
            color: isTh
                ? (isDark ? Colors.white.withValues(alpha: 0.06) : cs.surfaceContainerHighest.withValues(alpha: 0.7))
                : null,
            child: Text(
              cellText,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: cs.onSurface,
                fontWeight: isTh ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }
    }

    // Ensure at least one cell
    if (cells.isEmpty) {
      cells.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text('', style: TextStyle(color: cs.onSurface, fontSize: 13)),
      ));
    }

    return TableRow(children: cells);
  }

  String _extractCellText(md.Node node) {
    if (node is md.Text) return node.text;
    if (node is md.Element) {
      final buf = StringBuffer();
      for (final c in node.children ?? []) {
        buf.write(_extractCellText(c));
      }
      // For inline code, wrap with backticks for clarity
      if (node.tag == 'code') return buf.toString();
      return buf.toString();
    }
    return '';
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
