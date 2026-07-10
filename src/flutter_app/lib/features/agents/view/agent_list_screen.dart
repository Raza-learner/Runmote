import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connection_provider.dart';
import '../../../core/models/connection_state.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/agent_card.dart';
import 'widgets/agent_logo.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/status_badge.dart';

class AgentListScreen extends ConsumerStatefulWidget {
  const AgentListScreen({super.key});

  @override
  ConsumerState<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends ConsumerState<AgentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(connectionProvider.notifier).loadAgents();
    });
  }

  void _showAgentDetail(AcpAgent agent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AgentDetailSheet(agent: agent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Optimized: Select only necessary state parts to minimize rebuilds
    final connectionState = ref.watch(connectionProvider.select((c) => c.state));
    final agents = ref.watch(connectionProvider.select((c) => c.agents));
    final daemonConnected = ref.watch(connectionProvider.select((c) => c.daemonConnected));
    final pairingCode = ref.watch(connectionProvider.select((c) => c.pairingCode));
    final relayUrl = ref.watch(connectionProvider.select((c) => c.relayUrl));
    final selectedAgentId = ref.watch(connectionProvider.select((c) => c.selectedAgentId));

    final isConnected = connectionState is Connected;
    final isReconnecting = connectionState is Reconnecting;
    final isConnecting = connectionState is Connecting;
    final daemonDown = isConnected && !daemonConnected;

    AgentStatus status;
    if (isReconnecting || isConnecting) {
      status = AgentStatus.connecting;
    } else if (daemonDown) {
      status = AgentStatus.daemonOffline;
    } else if (isConnected) {
      status = AgentStatus.online;
    } else {
      status = AgentStatus.offline;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          pairingCode != null
              ? '${pairingCode.substring(0, 3)}-${pairingCode.substring(3)}'
              : 'Agents',
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: StatusLabel(status: status),
          ),
        ],
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Column(
        children: [
          // Adjust for transparent app bar
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          if (!isConnected && pairingCode != null)
            ErrorBanner(
              message: isReconnecting
                  ? 'Reconnecting...'
                  : 'Connection lost. Tap to reconnect.',
              onRetry: () {
                if (pairingCode != null) {
                  ref.read(connectionProvider.notifier).connect(
                    pairingCode,
                    relayUrl: relayUrl,
                  );
                }
              },
            ),
          Expanded(
            child: daemonDown
                ? _DaemonOfflineState(
                    onRefresh: () async {
                      ref.read(connectionProvider.notifier).loadAgents();
                    },
                  )
                : isConnected && agents.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          ref.read(connectionProvider.notifier).loadAgents();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: agents.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final agent = agents[index];
                            return AgentCard(
                              id: agent.id,
                              name: agent.name,
                              version: agent.version,
                              isOnline: agent.online,
                              isSelected:
                                  agent.id == selectedAgentId,
                              onTap: agent.online
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(connectionProvider.notifier)
                                          .selectAgent(agent.id);
                                      context.go('/sessions');
                                    }
                                  : null,
                              onInfoTap: () => _showAgentDetail(agent),
                            );
                          },
                        ),
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
                              isReconnecting || isConnecting
                                  ? 'Connecting...'
                                  : 'No agents detected',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Make sure a Runmote agent is running on your PC.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (isReconnecting || isConnecting)
                              const CircularProgressIndicator(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AgentDetailSheet extends StatelessWidget {
  final AcpAgent agent;

  const _AgentDetailSheet({required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Hero(
                  tag: 'agent-logo-${agent.id}',
                  child: AgentLogo(id: agent.id, name: agent.name, size: 56),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusLabel(
                        status: agent.online
                            ? AgentStatus.online
                            : AgentStatus.offline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              icon: Icons.fingerprint,
              label: 'Agent ID',
              value: agent.id,
            ),
            if (agent.version.isNotEmpty)
              _DetailRow(
                icon: Icons.tag_outlined,
                label: 'Version',
                value: 'v${agent.version}',
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaemonOfflineState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _DaemonOfflineState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Center(
            child: Icon(
              Icons.power_off_rounded,
              size: 72,
              color: AppColors.daemonOffline,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Daemon is not running',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'The daemon on your remote device is offline. '
              'Start it on the remote machine to reconnect.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to start the daemon',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Run this command on your remote device:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'runmote',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'The daemon will reconnect automatically once started. '
                  'Pull down to refresh.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
