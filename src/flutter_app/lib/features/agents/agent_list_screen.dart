import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/connection_provider.dart';
import '../../core/models/connection_state.dart';

class AgentListScreen extends ConsumerWidget {
  const AgentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionProvider);

    final isConnected = connection.state is Connected;
    final isReconnecting = connection.state is Reconnecting;
    final agentInfo = connection.agentInfo;

    Color statusColor;
    if (isConnected) {
      statusColor = Colors.green;
    } else if (isReconnecting) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              connection.pairingCode != null
                  ? '${connection.pairingCode!.substring(0, 3)}-${connection.pairingCode!.substring(3)}'
                  : 'Not connected',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              isConnected
                  ? 'Connected'
                  : isReconnecting
                      ? 'Reconnecting...'
                      : 'Disconnected',
              style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                context.go('/settings');
              } else if (value == 'disconnect') {
                ref.read(connectionProvider.notifier).disconnect();
                context.go('/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'disconnect', child: Text('Disconnect')),
            ],
          ),
        ],
      ),
      body: isConnected && agentInfo != null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AgentCard(
                  name: agentInfo.name,
                  version: agentInfo.version,
                  isOnline: true,
                  onTap: () => context.go('/sessions'),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No agents detected',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure an ACP agent is running on your PC.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isReconnecting || connection.state is Connecting)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final String name;
  final String version;
  final bool isOnline;
  final VoidCallback onTap;

  const _AgentCard({
    required this.name,
    required this.version,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.smart_toy,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('v$version'),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
