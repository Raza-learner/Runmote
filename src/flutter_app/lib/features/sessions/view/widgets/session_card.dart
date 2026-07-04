import 'package:flutter/material.dart';

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
    return Opacity(
      opacity: isOffline ? 0.6 : 1.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isOffline ? 0 : 2,
        child: InkWell(
          onTap: isOffline ? null : onTap,
          child: Padding(
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
                            .withValues(alpha: isOffline ? 0.2 : 0.5),
                        borderRadius: BorderRadius.circular(14),
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
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
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
                          fontWeight: FontWeight.bold,
                          color: isOffline ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cwd,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
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
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  onPressed: onDelete,
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
