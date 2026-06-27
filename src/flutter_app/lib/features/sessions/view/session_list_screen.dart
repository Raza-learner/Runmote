import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/session_list_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/session_card.dart';
import 'widgets/directory_picker_sheet.dart';

class SessionListScreen extends ConsumerStatefulWidget {
  const SessionListScreen({super.key});

  @override
  ConsumerState<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends ConsumerState<SessionListScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';
  String? _lastAgentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionListProvider.notifier).loadSessions();
    });
  }

  void _confirmDelete(AcpSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(
          session.title ?? 'Untitled',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(sessionListProvider.notifier)
                  .deleteSession(session.id);
              ref
                  .read(sessionListProvider.notifier)
                  .deleteSessionRemote(session.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    final db = ref.read(databaseProvider);
    final savedCwd = await db.getDefaultCwd();

    // If no saved cwd, request the laptop's home directory
    String initialPath;
    if (savedCwd != null) {
      initialPath = savedCwd;
    } else {
      final notifier = ref.read(connectionProvider.notifier);
      final completer = Completer<String>();
      int? reqId;
      StreamSubscription<Map<String, dynamic>>? sub;
      sub = notifier.messages.listen((msg) {
        if (msg['id'] == reqId) {
          sub?.cancel();
          final result = msg['result'] as Map<String, dynamic>?;
          if (result != null) {
            completer.complete(result['home'] as String? ?? '/home');
          } else {
            completer.complete('/home');
          }
        }
      });
      reqId = notifier.getHome();
      initialPath = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          sub?.cancel();
          return '/home';
        },
      );
    }

    if (!mounted) return;
    final pickedPath = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DirectoryPickerSheet(
        initialPath: initialPath,
        onSelected: (path) => Navigator.of(ctx).pop(path),
      ),
    );
    if (pickedPath == null || !mounted) return;

    await db.setDefaultCwd(pickedPath);
    final session = await ref.read(sessionListProvider.notifier).createSession(pickedPath);
    if (session == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create session — daemon may be disconnected')),
      );
    }
  }

  String _timeAgo(double timestamp) {
    if (timestamp <= 0) return '';
    final diff = DateTime.now().millisecondsSinceEpoch - (timestamp * 1000).toInt();
    final seconds = diff ~/ 1000;
    if (seconds < 60) return 'just now';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '${hours}h ago';
    final days = hours ~/ 24;
    if (days < 7) return '${days}d ago';
    return '${days ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionProvider);
    final sessionsAsync = ref.watch(sessionListProvider);

    if (connection.selectedAgentId != _lastAgentId) {
      _lastAgentId = connection.selectedAgentId;
      if (connection.selectedAgentId != null) {
        Future.microtask(() {
          ref.read(sessionListProvider.notifier).loadSessions();
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search sessions...',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.titleMedium,
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sessions',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    connection.agentInfo?.name ?? 'Agent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                _searchQuery = '';
              }
            }),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          final supportsSessionList =
              connection.capabilities?.supportsSessionList ?? true;
          final filtered = _searchQuery.isEmpty
              ? sessions
              : sessions
                  .where((s) =>
                      (s.title ?? '')
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      s.cwd.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              if (!supportsSessionList && sessions.isNotEmpty)
                _LocalOnlyBanner(),
              Expanded(
                child: _buildSessionList(
                  theme, filtered, sessions, _searchQuery,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSession,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSessionList(
    ThemeData theme,
    List<AcpSession> filtered,
    List<AcpSession> sessions,
    String searchQuery,
  ) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Start your first session',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createSession,
              icon: const Icon(Icons.add),
              label: const Text('New Session'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions match "$searchQuery"',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sessionListProvider.notifier).loadSessions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final session = filtered[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SessionCard(
              title: session.title,
              cwd: session.cwd,
              timeAgo: _timeAgo(session.updatedAt),
                    onTap: () {
                      final cwd = session.cwd;
                      final path = cwd.isNotEmpty
                          ? '/chat/${session.id}?cwd=${Uri.encodeComponent(cwd)}'
                          : '/chat/${session.id}';
                      context.push(path);
                    },
              onDelete: () {
                _confirmDelete(session);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LocalOnlyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: theme.colorScheme.tertiaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This agent doesn\'t support session listing from remote device — showing locally stored sessions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
