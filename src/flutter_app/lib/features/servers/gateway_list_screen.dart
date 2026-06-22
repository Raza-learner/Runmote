import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/gateway_provider.dart';
import '../../core/models/gateway_source.dart';

class GatewayListScreen extends ConsumerStatefulWidget {
  const GatewayListScreen({super.key});

  @override
  ConsumerState<GatewayListScreen> createState() => _GatewayListScreenState();
}

class _GatewayListScreenState extends ConsumerState<GatewayListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gatewayListProvider.notifier).loadGateways();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateways = ref.watch(gatewayListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gateways'),
      ),
      body: gateways.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.devices, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No gateways paired',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pair a gateway to discover agents on your network',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(gatewayListProvider.notifier).loadGateways(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gateways.length,
                itemBuilder: (context, index) {
                  final g = gateways[index];
                  return _GatewayTile(
                    gateway: g,
                    onTap: () {
                      context.push('/gateways/${g.id}/agents');
                    },
                    onDelete: () => _deleteGateway(g),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _deleteGateway(GatewaySource gateway) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Gateway'),
        content: Text('Remove "${gateway.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(gatewayListProvider.notifier).deleteGateway(gateway.id);
    }
  }
}

class _GatewayTile extends StatelessWidget {
  final GatewaySource gateway;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GatewayTile({
    required this.gateway,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.devices, color: theme.colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${gateway.scheme}://${gateway.host}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
