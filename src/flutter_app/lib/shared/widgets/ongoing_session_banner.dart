import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/connection_provider.dart';
import '../../core/providers/session_list_provider.dart';

class OngoingSessionBanner extends ConsumerWidget {
  const OngoingSessionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIds = ref.watch(activeSessionsProvider);
    final connection = ref.watch(connectionProvider);
    
    if (activeIds.isEmpty || !connection.daemonConnected) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final latestId = ref.read(activeSessionsProvider.notifier).latestSessionId;
    final agentName = connection.agentInfo?.name ?? 'Agent';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: () {
          if (latestId != null) {
            final sessions = ref.read(sessionListProvider).valueOrNull ?? [];
            final session = sessions.where((s) => s.id == latestId).firstOrNull;
            final cwd = session?.cwd ?? '';
            final path = cwd.isNotEmpty
                ? '/chat/$latestId?cwd=${Uri.encodeComponent(cwd)}'
                : '/chat/$latestId';
            context.push(path);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activeIds.length == 1
                      ? '$agentName is responding...'
                      : '${activeIds.length} sessions active',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
