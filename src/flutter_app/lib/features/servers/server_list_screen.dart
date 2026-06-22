import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/connection_provider.dart';
import '../../core/providers/server_list_provider.dart';
import '../../core/providers/gateway_provider.dart';
import '../../core/models/connection_state.dart';
import '../../core/models/server_config.dart' as model;

class ServerListScreen extends ConsumerStatefulWidget {
  const ServerListScreen({super.key});

  @override
  ConsumerState<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends ConsumerState<ServerListScreen> {
  bool _showFabMenu = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(connectionProvider.notifier);
      ref.read(serverListProvider.notifier).loadServers();
      ref.read(gatewayListProvider.notifier).loadGateways();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionProvider);
    final servers = ref.watch(serverListProvider);
    final gateways = ref.watch(gatewayListProvider);
    final theme = Theme.of(context);
    final hasServers = servers.isNotEmpty || gateways.isNotEmpty;

    return PopScope(
      canPop: !_showFabMenu,
      onPopInvokedWithResult: (didPop, _) {
        if (_showFabMenu) {
          setState(() => _showFabMenu = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            hasServers ? 'ACP Remote' : 'ACP Remote',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            _ConnectionIndicator(state: connectionState),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: hasServers ? _buildServerList(servers, gateways, theme) : _buildEmptyState(theme),
        floatingActionButton: _buildFabMenu(theme),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No agents configured',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an ACP agent or pair a gateway to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _navigateToAddServer(),
            icon: const Icon(Icons.add),
            label: const Text('Add Agent'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _navigateToPairGateway(),
            icon: const Icon(Icons.link),
            label: const Text('Pair Gateway'),
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(
    List<model.ServerConfig> servers,
    List<dynamic> gateways,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(serverListProvider.notifier).loadServers();
        await ref.read(gatewayListProvider.notifier).loadGateways();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          if (servers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
              child: Text(
                'Agents',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...servers.map((s) => _ServerCard(
                  server: s,
                  onTap: () => _openSessions(s.id, s.name),
                  onEdit: () => _navigateToEditServer(s),
                  onDelete: () => _deleteServer(s.id),
                )),
          ],
          if (gateways.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
              child: Text(
                'Gateways',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...gateways.map((g) => _GatewayCard(
                  gateway: g as dynamic,
                  onTap: () => _navigateToGatewayAgents(g.id),
                  onEdit: () {},
                  onDelete: () => _deleteGateway(g.id),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: _navigateToGateways,
                icon: const Icon(Icons.devices, size: 18),
                label: const Text('Manage Gateways'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFabMenu(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showFabMenu) ...[
          FloatingActionButton.small(
            heroTag: 'pair_gateway',
            backgroundColor: theme.colorScheme.secondaryContainer,
            onPressed: () {
              setState(() => _showFabMenu = false);
              _navigateToPairGateway();
            },
            child: Icon(Icons.link, color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_server',
            backgroundColor: theme.colorScheme.primaryContainer,
            onPressed: () {
              setState(() => _showFabMenu = false);
              _navigateToAddServer();
            },
            child: Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: () => setState(() => _showFabMenu = !_showFabMenu),
          child: Icon(_showFabMenu ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  void _navigateToAddServer() {
    context.push('/servers/add');
  }

  void _navigateToEditServer(model.ServerConfig server) {
    context.push('/servers/edit', extra: server);
  }

  void _navigateToPairGateway() {
    context.push('/gateways/pair');
  }

  void _navigateToGateways() {
    context.push('/gateways');
  }

  void _navigateToGatewayAgents(String gatewayId) {
    context.push('/gateways/$gatewayId/agents');
  }

  void _openSessions(String serverId, String name) {
    context.push('/sessions/$serverId', extra: name);
  }

  Future<void> _deleteServer(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Agent'),
        content: const Text('Are you sure you want to remove this agent?'),
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
      await ref.read(serverListProvider.notifier).deleteServer(id);
    }
  }

  Future<void> _deleteGateway(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Gateway'),
        content: const Text('Are you sure you want to remove this gateway?'),
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
      await ref.read(gatewayListProvider.notifier).deleteGateway(id);
    }
  }
}

class _ServerCard extends StatelessWidget {
  final model.ServerConfig server;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServerCard({
    required this.server,
    required this.onTap,
    required this.onEdit,
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
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${server.scheme}://${server.host}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  final dynamic gateway;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GatewayCard({
    required this.gateway,
    required this.onTap,
    required this.onEdit,
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
                child: Icon(
                  Icons.devices,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${gateway.scheme}://${gateway.host}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final AcpConnectionState state;

  const _ConnectionIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      Disconnected() => Colors.grey,
      Connecting() => Colors.orange,
      Connected() => Colors.green,
      Reconnecting() => Colors.red,
      Failed() => Colors.red,
    };

    return Tooltip(
      message: state.when(
        disconnected: () => 'Disconnected',
        connecting: () => 'Connecting...',
        connected: () => 'Connected',
        reconnecting: () => 'Reconnecting...',
        failed: (e) => 'Connection failed${e != null ? ': $e' : ''}',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
