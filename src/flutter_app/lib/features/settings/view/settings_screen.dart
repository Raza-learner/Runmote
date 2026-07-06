import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/preferences_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/models/mcp_server.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionProvider);
    final themeMode = ref.watch(themeModeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _SectionHeader(title: 'Connection'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.wifi_rounded),
                  title: const Text('Connection Status'),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connection.daemonConnected ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(connection.daemonConnected ? 'Connected to Relay' : 'Connecting to Relay...'),
                    ],
                  ),
                  trailing: connection.relayUrl != null ? IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Relay Details'),
                          content: SelectableText(connection.relayUrl!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ) : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.link,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Pairing Code'),
                  subtitle: Text(
                    connection.pairingCode != null
                        ? '${connection.pairingCode!.substring(0, 3)}-${connection.pairingCode!.substring(3)}'
                        : 'Not paired',
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.link_off, color: theme.colorScheme.error),
                  title: const Text('Unpair Device'),
                  subtitle: const Text('Disconnect and return to pair screen'),
                  onTap: () => _confirmUnpair(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'MCP Servers'),
          const SizedBox(height: AppSpacing.sm),
          _McpServersSection(),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Color Scheme'),
                  subtitle: Text(
                    _schemeName(ref.watch(flexSchemeProvider)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSchemePicker(context, ref),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode_rounded
                                : themeMode == ThemeMode.light
                                    ? Icons.light_mode_rounded
                                    : Icons.brightness_auto_rounded,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 16),
                          Text('Theme Mode', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto, size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode, size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode, size: 18),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (set) {
                            final mode = set.first;
                            ref.read(themeModeStateProvider.notifier).state = mode;
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('theme_mode', mode.name);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'Data'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Default Working Directory'),
                  subtitle: Text(
                    ref.watch(defaultCwdProvider).valueOrNull ?? '/home',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _editDefaultCwd(context, ref),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  title: const Text('Clear Local Data'),
                  subtitle: const Text('Remove all cached messages and sessions'),
                  onTap: () => _confirmClearData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'About'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Documentation'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    // Open docs URL
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report an Issue'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    // Open GitHub issues
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  'ACP Remote v2.0.0',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crafted with ❤️ for Developers',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _schemeName(FlexScheme scheme) {
    return scheme.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}')
        .trim()
        .replaceFirst(scheme.name[0], scheme.name[0].toUpperCase());
  }

  static const _schemeGroups = [
    ('Shadcn', [
      FlexScheme.shadNeutral,
      FlexScheme.shadSlate,
      FlexScheme.shadStone,
      FlexScheme.shadZinc,
      FlexScheme.shadGray,
      FlexScheme.shadViolet,
      FlexScheme.shadBlue,
      FlexScheme.shadGreen,
      FlexScheme.shadOrange,
      FlexScheme.shadRed,
      FlexScheme.shadRose,
      FlexScheme.shadYellow,
    ]),
    ('Material 3', [
      FlexScheme.indigoM3,
      FlexScheme.blueM3,
      FlexScheme.cyanM3,
      FlexScheme.tealM3,
      FlexScheme.greenM3,
      FlexScheme.limeM3,
      FlexScheme.yellowM3,
      FlexScheme.orangeM3,
      FlexScheme.redM3,
      FlexScheme.pinkM3,
      FlexScheme.purpleM3,
      FlexScheme.deepOrangeM3,
    ]),
    ('Classic', [
      FlexScheme.indigo,
      FlexScheme.blue,
      FlexScheme.deepBlue,
      FlexScheme.aquaBlue,
      FlexScheme.brandBlue,
      FlexScheme.green,
      FlexScheme.jungle,
      FlexScheme.mango,
      FlexScheme.amber,
      FlexScheme.gold,
      FlexScheme.mandyRed,
      FlexScheme.red,
      FlexScheme.deepPurple,
      FlexScheme.sakura,
      FlexScheme.espresso,
      FlexScheme.barossa,
    ]),
  ];

  void _showSchemePicker(BuildContext context, WidgetRef ref) {
    final current = ref.watch(flexSchemeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Color Scheme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: _schemeGroups.map((group) {
                    final label = group.$1;
                    final schemes = group.$2;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: schemes.map((scheme) {
                            final selected = scheme == current;
                            final colors = scheme.colors(
                              Theme.of(context).brightness,
                            );
                            return FilterChip(
                              selected: selected,
                              label: Text(
                                scheme.name.replaceAllMapped(
                                  RegExp(r'[A-Z]'),
                                  (m) => ' ${m.group(0)}',
                                ).trim(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              avatar: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onSelected: (_) {
                                ref.read(flexSchemeProvider.notifier).state = scheme;
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setString('flex_scheme', scheme.name);
                                });
                                Navigator.of(ctx).pop();
                              },
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editDefaultCwd(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final controller = TextEditingController(
      text: ref.read(defaultCwdProvider).valueOrNull ?? '/home',
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
            onPressed: () async {
              ref.read(connectionProvider.notifier).disconnect();
              final p = await ref.read(preferencesServiceProvider.future);
              await p.clearAuthToken();
              await p.clearPairingCode();
              await p.clearRelayUrl();
              if (ctx.mounted) Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _McpServersSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_McpServersSection> createState() => _McpServersSectionState();
}

class _McpServersSectionState extends ConsumerState<_McpServersSection> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(preferencesServiceProvider.future);
    ref.read(mcpServersProvider.notifier).load(prefs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final servers = ref.watch(mcpServersProvider);

    return Card(
      child: Column(
        children: [
          if (servers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No MCP servers configured'),
            )
          else
            ...servers.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.extension, color: theme.colorScheme.primary),
                    title: Text(s.name),
                    subtitle: Text(
                      s.command,
                      style: const TextStyle(fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      onPressed: () => _confirmDelete(context, i, s.name),
                    ),
                    onTap: () => _editMcpServer(context, i),
                  ),
                ],
              );
            }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.add, color: theme.colorScheme.primary),
            title: const Text('Add MCP server'),
            onTap: () => _addMcpServer(context),
          ),
        ],
      ),
    );
  }

  void _addMcpServer(BuildContext context) {
    _showMcpServerDialog(context);
  }

  void _editMcpServer(BuildContext context, int index) {
    final server = ref.read(mcpServersProvider)[index];
    _showMcpServerDialog(context, index: index, server: server);
  }

  void _confirmDelete(BuildContext context, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove MCP server?'),
        content: Text('Remove "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final prefs = await ref.read(preferencesServiceProvider.future);
              ref.read(mcpServersProvider.notifier).remove(prefs, index);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showMcpServerDialog(BuildContext context,
      {int? index, McpServer? server}) {
    final nameCtrl = TextEditingController(text: server?.name ?? '');
    final cmdCtrl = TextEditingController(text: server?.command ?? '');
    final argsCtrl = TextEditingController(
      text: server?.args.join(' ') ?? '',
    );
    final urlCtrl = TextEditingController(text: server?.url ?? '');

    final isHttpState = ValueNotifier(server?.type == 'http');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(index != null ? 'Edit MCP server' : 'Add MCP server'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'filesystem',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: isHttpState,
                    builder: (ctx, isHttp, _) => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'stdio', label: Text('STDIO')),
                        ButtonSegment(value: 'http', label: Text('HTTP')),
                      ],
                      selected: {isHttp ? 'http' : 'stdio'},
                      onSelectionChanged: (set) {
                        isHttpState.value = set.first == 'http';
                        setDialogState(() {});
                      },
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isHttpState,
                    builder: (ctx, isHttp, _) {
                      if (isHttp) {
                        return TextField(
                          controller: urlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL',
                            hintText: 'https://api.example.com/mcp',
                            border: OutlineInputBorder(),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          TextField(
                            controller: cmdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Command',
                              hintText: '/path/to/mcp-server',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: argsCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Arguments',
                              hintText: '--stdio --debug',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final prefs = await ref.read(preferencesServiceProvider.future);
                  final notifier = ref.read(mcpServersProvider.notifier);
                  final isHttp = isHttpState.value;
                  final mcp = McpServer(
                    name: nameCtrl.text.trim(),
                    command: isHttp ? '' : cmdCtrl.text.trim(),
                    args: isHttp ? [] : argsCtrl.text
                        .split(' ')
                        .where((a) => a.isNotEmpty)
                        .toList(),
                    type: isHttp ? 'http' : 'stdio',
                    url: isHttp ? urlCtrl.text.trim() : null,
                  );
                  if (index != null) {
                    notifier.update(prefs, index, mcp);
                  } else {
                    notifier.add(prefs, mcp);
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
