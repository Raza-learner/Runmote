import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';

class SessionCard extends StatelessWidget {
  final String? title;
  final String cwd;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isActive;
  final bool isOffline;

  const SessionCard({
    super.key,
    this.title,
    required this.cwd,
    required this.timeAgo,
    required this.onTap,
    required this.onDelete,
    this.isActive = false,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: isOffline ? 0.6 : 1.0,
      child: Material(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        elevation: 0,
        child: InkWell(
          onTap: isOffline
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: isOffline ? 0.2 : 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isOffline ? Icons.cloud_off_rounded : Icons.chat_bubble_outline,
                        size: 22,
                        color: isOffline
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (isActive && !isOffline)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Semantics(label: 'Active session', child: _PulsingDot(isDark: isDark)),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Untitled Session',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: isOffline ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cwd,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          letterSpacing: 0.2,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isOffline) ...[
                            Text(
                              'OFFLINE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timeAgo,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              letterSpacing: 0.2,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45)),
                  tooltip: 'More actions',
                  onSelected: (v) async {
                    if (v == 'copy_cwd') {
                      await Clipboard.setData(ClipboardData(text: cwd));
                      HapticFeedback.lightImpact();
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CWD copied'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'copy_cwd', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Copy path')])),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  onPressed: () { HapticFeedback.lightImpact(); onDelete(); },
                  tooltip: 'Delete session',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final bool isDark;
  const _PulsingDot({required this.isDark});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.25).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 12 * _scale.value,
            height: 12 * _scale.value,
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.25), shape: BoxShape.circle),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: widget.isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
