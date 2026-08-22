import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: isSelected ? 1.2 : 1,
            ),
          ),
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
                        letterSpacing: -0.1,
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
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onInfoTap!();
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
