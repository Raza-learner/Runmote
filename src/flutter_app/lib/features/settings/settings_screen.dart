import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/connection_provider.dart';
import '../../core/providers/database_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('General', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Default working directory'),
                  subtitle: Text(
                    connection.pairingCode ?? '/home',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editDefaultCwd(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: const Text('System'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePicker(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Data', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Clear local data'),
                  subtitle: const Text(
                      'Remove all cached messages and settings'),
                  trailing: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  onTap: () => _confirmClearData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Unpair device'),
                  subtitle: Text(
                    connection.pairingCode != null
                        ? '${connection.pairingCode!.substring(0, 3)}-${connection.pairingCode!.substring(3)}'
                        : 'Not paired',
                  ),
                  trailing: Icon(Icons.link_off,
                      color: theme.colorScheme.error),
                  onTap: () => _confirmUnpair(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'ACP Remote v2.0.0',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDefaultCwd(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final controller = TextEditingController(
      text: ref.read(connectionProvider).pairingCode ?? '/home',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default working directory'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/home/user',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await db.setDefaultCwd(controller.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Theme'),
        children: ['System', 'Light', 'Dark'].map((mode) {
          return SimpleDialogOption(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('theme_mode', mode.toLowerCase());
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(mode),
          );
        }).toList(),
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear local data?'),
        content: const Text(
          'This will remove all cached messages and sessions. '
          'Your pairing will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(databaseProvider).clearAll();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local data cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmUnpair(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unpair device?'),
        content: const Text(
          'You will need to enter the pairing code again to reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(connectionProvider.notifier).disconnect();
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
  }
}
