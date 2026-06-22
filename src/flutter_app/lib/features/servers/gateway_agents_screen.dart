import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/gateway_provider.dart';
import '../../core/providers/preferences_provider.dart';
import '../dialogs/launch_risk_consent_dialog.dart';

class GatewayAgentsScreen extends ConsumerStatefulWidget {
  final String gatewayId;

  const GatewayAgentsScreen({super.key, required this.gatewayId});

  @override
  ConsumerState<GatewayAgentsScreen> createState() => _GatewayAgentsScreenState();
}

class _GatewayAgentsScreenState extends ConsumerState<GatewayAgentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gatewayAgentsProvider(widget.gatewayId).notifier)
          .loadAgents(widget.gatewayId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final agents = ref.watch(gatewayAgentsProvider(widget.gatewayId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gateway Agents'),
      ),
      body: agents.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy_outlined, size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No agents found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This gateway has no registered agents',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _launchAgent(agent.name, agent.agentId),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.smart_toy,
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agent.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Agent ID: ${agent.agentId.substring(0, 12)}...',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _launchAgent(String agentName, String agentId) async {
    final prefs = await ref.read(preferencesServiceProvider.future);
    if (!mounted) return;

    if (!prefs.consentDismissed) {
      final consent = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => LaunchRiskConsentDialog(
          preferences: prefs,
          onConsent: () => Navigator.pop(ctx, true),
          onDismiss: () => Navigator.pop(ctx, false),
        ),
      );
      if (consent != true) return;
    }

    if (!mounted) return;
    context.push('/sessions/$agentId', extra: agentName);
  }
}
