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
    final notifier = ref.read(activeSessionsProvider.notifier);
    final latestId = notifier.latestSessionId;
    // Resolve the agent that actually owns the active session, not the
    // currently selected agent in the UI. Falls back to selected agent.
    String? activeAgentId;
    if (latestId != null) activeAgentId = notifier.agentIdFor(latestId);
    activeAgentId ??= activeIds.isNotEmpty
        ? notifier.agentIdFor(activeIds.first)
        : null;
    String agentName = connection.agentInfo?.name ?? 'Agent';
    if (activeAgentId != null) {
      final agent = connection.agents
          .where((a) => a.id == activeAgentId)
          .firstOrNull;
      if (agent != null) agentName = agent.name;
    }
    final label = activeIds.length == 1
        ? '$agentName is responding...'
        : '${activeIds.length} sessions active';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
