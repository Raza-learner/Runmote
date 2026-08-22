import 'dart:ui' as ui;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/env.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/preferences_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/models/mcp_server.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/animated_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionProvider);
    final themeMode = ref.watch(themeModeStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.4),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: AnimatedBackground(
        showGrid: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
          ),
          children: [
          _SectionHeader(title: AppLocalizations.of(context)!.settingsConnection),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.wifi_rounded),
                  title: Text(AppLocalizations.of(context)!.settingsConnectionStatus),
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
                      Text(connection.daemonConnected ? AppLocalizations.of(context)!.settingsConnectedToRelay : AppLocalizations.of(context)!.settingsConnectingToRelay),
                    ],
                  ),
                  trailing: connection.relayUrl != null ? IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () {
                      final url = connection.relayUrl!;
                      final isCloud = isCloudRelay(url);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.settingsRelayDetails),
                          content: isCloud
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      relayDisplayName(url),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      relayDisplaySubtitle(url),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                )
                              : SelectableText(url),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(AppLocalizations.of(context)!.settingsClose),
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
                  title: Text(AppLocalizations.of(context)!.settingsPairingCode),
                  subtitle: Text(
                    connection.pairingCode != null
                        ? '${connection.pairingCode!.substring(0, 3)}-${connection.pairingCode!.substring(3)}'
                        : AppLocalizations.of(context)!.settingsNotPaired,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.link_off, color: theme.colorScheme.error),
                  title: Text(AppLocalizations.of(context)!.settingsUnpairDevice),
                  subtitle: Text(AppLocalizations.of(context)!.settingsUnpairSubtitle),
                  onTap: () => _confirmUnpair(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: AppLocalizations.of(context)!.settingsMcpServers),
          const SizedBox(height: AppSpacing.sm),
          _McpServersSection(),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: AppLocalizations.of(context)!.settingsAppearance),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(AppLocalizations.of(context)!.settingsColorScheme),
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
                          Text(AppLocalizations.of(context)!.settingsThemeMode),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text(AppLocalizations.of(context)!.settingsThemeSystem),
                              icon: Icon(Icons.brightness_auto, size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text(AppLocalizations.of(context)!.settingsThemeLight),
                              icon: Icon(Icons.light_mode, size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text(AppLocalizations.of(context)!.settingsThemeDark),
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
          _SectionHeader(title: AppLocalizations.of(context)!.settingsData),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  title: Text(AppLocalizations.of(context)!.settingsClearLocalData),
                  subtitle: Text(AppLocalizations.of(context)!.settingsClearLocalDataSubtitle),
                  onTap: () => _confirmClearData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: AppLocalizations.of(context)!.settingsAbout),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(AppLocalizations.of(context)!.settingsReportIssue),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () {
                    launchUrl(Uri.parse('https://github.com/Raza-learner/Runmote/pulls'));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '';
                    // Show placeholder while loading to avoid flicker:
                    if (version.isEmpty) {
                      return Text(
                        AppLocalizations.of(context)!.settingsVersion('...'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      );
                    }
                    return Text(
                      AppLocalizations.of(context)!.settingsVersion(version),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.settingsFooter,
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

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l!.settingsClearDataTitle),
        content: Text(l.settingsClearDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.settingsCancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(databaseProvider).clearAll();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.settingsDataCleared)),
              );
            },
            child: Text(l.settingsClear),
          ),
        ],
      ),
    );
  }

  void _confirmUnpair(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l!.settingsUnpairTitle),
        content: Text(l.settingsUnpairBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.settingsCancel),
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
            child: Text(l.settingsUnpairConfirm),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(context)!.settingsMcpEmpty),
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
            title: Text(AppLocalizations.of(context)!.settingsAddMcp),
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
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l!.settingsRemoveMcpTitle),
        content: Text(l.settingsRemoveMcpConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.settingsCancel),
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
            child: Text(l.settingsRemove),
          ),
        ],
      ),
    );
  }

  void _showMcpServerDialog(BuildContext context,
      {int? index, McpServer? server}) {
    final l = AppLocalizations.of(context);
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
            title: Text(index != null ? l!.settingsEditMcp : l!.settingsAddMcp),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l.settingsMcpName,
                      hintText: l.settingsMcpNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: isHttpState,
                    builder: (ctx, isHttp, _) => SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'stdio', label: Text(l.settingsStdio)),
                        ButtonSegment(value: 'http', label: Text(l.settingsHttp)),
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
                          decoration: InputDecoration(
                            labelText: l.settingsUrl,
                            hintText: l.settingsUrlHint,
                            border: const OutlineInputBorder(),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          TextField(
                            controller: cmdCtrl,
                            decoration: InputDecoration(
                              labelText: l.settingsCommand,
                              hintText: l.settingsCommandHint,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: argsCtrl,
                            decoration: InputDecoration(
                              labelText: l.settingsArguments,
                              hintText: l.settingsArgumentsHint,
                              border: const OutlineInputBorder(),
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
                child: Text(l.settingsCancel),
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
                child: Text(l.settingsSave),
              ),
            ],
          );
        },
      ),
    );
  }
}
