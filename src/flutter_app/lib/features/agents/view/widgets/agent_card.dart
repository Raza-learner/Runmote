import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'agent_logo.dart';
import '../../../../shared/widgets/status_badge.dart';

class AgentCard extends StatelessWidget {
  final String id;
  final String name;
  final String version;
  final bool isOnline;
  final bool isSelected;
  final int? sessionsCount;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  const AgentCard({
    super.key,
    required this.id,
    required this.name,
    required this.isOnline,
    this.version = '',
    this.isSelected = false,
    this.sessionsCount,
    this.onTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = isOnline ? AgentStatus.online : AgentStatus.offline;

    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Hero(
                    tag: 'agent-logo-$id',
                    child: AgentLogo(id: id, name: name),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            StatusLabel(status: status),
                            if (sessionsCount != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$sessionsCount',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  if (onInfoTap != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: onInfoTap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
