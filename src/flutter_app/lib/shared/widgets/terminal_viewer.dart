import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasOutput = widget.output != null && widget.output!.isNotEmpty;
    final lines = hasOutput ? widget.output!.split('\n') : <String>[];
    final previewLines = lines.length > 12 && !_expanded ? lines.sublist(0, 12) : lines;
    final overflow = lines.length - previewLines.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.12 : 0.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                const _TrafficDot(color: Color(0xFFFF5F56)),
                const SizedBox(width: 6),
                const _TrafficDot(color: Color(0xFFFFBD2E)),
                const SizedBox(width: 6),
                const _TrafficDot(color: Color(0xFF27C93F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Terminal ${widget.terminalId}',
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasOutput)
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: widget.output!));
                      HapticFeedback.lightImpact();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Terminal output copied'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.copy_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
              ],
            ),
          ),
          if (hasOutput)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < previewLines.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final l in previewLines)
                        Text(l.isEmpty ? ' ' : l, style: const TextStyle(color: Color(0xFFE5E7EB), fontFamily: 'monospace', fontSize: 11, height: 1.5)),
                    ],
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF27C93F))),
                  SizedBox(width: 10),
                  Text('Waiting for output…', style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'monospace', fontSize: 11)),
                ],
              ),
            ),
          if (overflow > 0)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(_expanded ? 'Collapse' : '+$overflow more lines', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  final Color color;
  const _TrafficDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black.withValues(alpha: 0.2))));
  }
}
