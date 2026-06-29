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
    if (activeIds.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final latestId = ref.read(activeSessionsProvider.notifier).latestSessionId;
    final connection = ref.watch(connectionProvider);
    final agentName = connection.agentInfo?.name ?? 'Agent';

    return GestureDetector(
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
          horizontal: 16,
          vertical: 10,
        ),
        color: theme.colorScheme.primaryContainer,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activeIds.length == 1
                    ? '$agentName is responding...'
                    : '${activeIds.length} sessions running',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
