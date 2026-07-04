import 'package:flutter/material.dart';

class TerminalViewer extends StatefulWidget {
  final String terminalId;
  final String? output;

  const TerminalViewer({
    super.key,
    required this.terminalId,
    this.output,
  });

  @override
  State<TerminalViewer> createState() => _TerminalViewerState();
}

class _TerminalViewerState extends State<TerminalViewer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOutput = widget.output != null && widget.output!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Terminal ${widget.terminalId}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (hasOutput)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.output!,
                style: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
