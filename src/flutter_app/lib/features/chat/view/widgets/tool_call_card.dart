import 'package:flutter/material.dart';
import '../../../../shared/widgets/diff_viewer.dart';
import '../../../../shared/widgets/terminal_viewer.dart';

class ToolCallCard extends StatefulWidget {
  final String name;
  final String? output;
  final List<Map<String, String>>? diffs;
  final String? terminalId;
  final bool isCompleted;
  final bool isStreaming;

  const ToolCallCard({
    super.key,
    required this.name,
    this.output,
    this.diffs,
    this.terminalId,
    this.isCompleted = false,
    this.isStreaming = true,
  });

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard> {
  bool _expanded = false;

  IconData get _icon {
    final lower = widget.name.toLowerCase();
    if (lower.contains('bash') || lower.contains('shell') || lower.contains('exec')) {
      return Icons.terminal;
    }
    if (lower.contains('read')) return Icons.file_open_outlined;
    if (lower.contains('write')) return Icons.edit_note;
    if (lower.contains('glob') || lower.contains('search')) return Icons.folder_open;
    if (lower.contains('python')) return Icons.code;
    return Icons.code;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasOutput = widget.output != null && widget.output!.isNotEmpty;
    final showRunning = widget.isStreaming && !widget.isCompleted && !hasOutput;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Tool: ${widget.name}',
            hint: hasOutput
                ? (_expanded ? 'Tap to collapse' : 'Tap to expand')
                : null,
            button: hasOutput,
            excludeSemantics: true,
            child: InkWell(
              onTap: hasOutput ? () => setState(() => _expanded = !_expanded) : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _icon,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showRunning)
                      Semantics(
                        label: 'Running',
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else if (widget.isCompleted)
                      Semantics(
                        label: 'Completed',
                        child: Icon(
                          Icons.check_circle,
                          size: 14,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    if (hasOutput)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (hasOutput || widget.diffs != null || widget.terminalId != null)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.terminalId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: TerminalViewer(
                          terminalId: widget.terminalId!,
                          output: widget.output,
                        ),
                      ),
                    if (widget.diffs != null)
                      ...widget.diffs!.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: DiffViewer(
                              oldText: d['oldText'] ?? '',
                              newText: d['newText'] ?? '',
                            ),
                          )),
                    if (hasOutput && widget.terminalId == null)
                      Text(
                        widget.output!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
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
