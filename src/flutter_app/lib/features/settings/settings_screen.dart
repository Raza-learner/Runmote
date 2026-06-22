import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/providers/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _relayUrlController;
  bool _isRelayChanged = false;

  @override
  void initState() {
    super.initState();
    _relayUrlController = TextEditingController();
    _loadRelayUrl();
  }

  @override
  void dispose() {
    _relayUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadRelayUrl() async {
    final prefs = await ref.read(preferencesServiceProvider.future);
    _relayUrlController.text = prefs.relayUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Connection', theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Relay URL', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _relayUrlController,
                    decoration: InputDecoration(
                      hintText: 'ws://localhost:8000/app',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      suffixIcon: _isRelayChanged
                          ? IconButton(
                              icon: Icon(Icons.check, color: theme.colorScheme.primary),
                              onPressed: _saveRelayUrl,
                            )
                          : null,
                    ),
                    onChanged: (_) {
                      if (!_isRelayChanged) setState(() => _isRelayChanged = true);
                    },
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveRelayUrl(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('Appearance', theme),
          Card(
            child: _ThemeSelector(
              onChanged: (mode) {
                final prefs = ref.read(preferencesServiceProvider).value;
                if (prefs != null) {
                  prefs.themeMode = mode;
                  ref.invalidate(preferencesServiceProvider);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('Privacy', theme),
          Card(
            child: _buildTelemetryToggle(theme),
          ),
          const SizedBox(height: 16),
          _sectionHeader('Data', theme),
          Card(
            child: _buildClearDataButton(theme),
          ),
          const SizedBox(height: 16),
          _sectionHeader('About', theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ACP Remote',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 2.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A cross-platform remote client for the Anthropic Computer Protocol (ACP). '
                    'Connect to ACP agents and gateways over a relay service.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.code, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'github.com/arafatamim/ferngeist-acp',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTelemetryToggle(ThemeData theme) {
    return ref.watch(preferencesServiceProvider).when(
      data: (prefs) => SwitchListTile(
        title: const Text('Telemetry'),
        subtitle: Text(
          'Send anonymous usage data to improve the app',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: prefs.telemetryEnabled,
        onChanged: (v) {
          prefs.telemetryEnabled = v;
          ref.invalidate(preferencesServiceProvider);
        },
      ),
      loading: () => const ListTile(title: Text('Telemetry'), trailing: CircularProgressIndicator()),
      error: (_, _) => const ListTile(title: Text('Telemetry')),
    );
  }

  Widget _buildClearDataButton(ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
      title: Text('Clear All Local Data', style: TextStyle(color: theme.colorScheme.error)),
      subtitle: Text(
        'Remove all servers, gateways, and sessions',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: _confirmClearData,
    );
  }

  Future<void> _saveRelayUrl() async {
    final url = _relayUrlController.text.trim();
    if (url.isEmpty) return;
    final prefs = await ref.read(preferencesServiceProvider.future);
    prefs.relayUrl = url;
    ref.invalidate(preferencesServiceProvider);
    setState(() => _isRelayChanged = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relay URL saved')),
      );
    }
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all servers, gateways, and sessions. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _clearData();
    }
  }

  Future<void> _clearData() async {
    final db = ref.read(databaseProvider);
    await db.delete(db.serverConfigs).go();
    await db.delete(db.gatewaySources).go();
    await db.delete(db.gatewayAgentBindings).go();
    await db.delete(db.sessionCache).go();
    await db.delete(db.sessionSettings).go();
    ref.invalidate(preferencesServiceProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All local data cleared')),
      );
    }
  }
}

class _ThemeSelector extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _ThemeSelector({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final asyncPrefs = ref.watch(preferencesServiceProvider);
      return asyncPrefs.when(
        data: (prefs) {
          final current = prefs.themeMode;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.settings_suggest)),
                    ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {current},
                  onSelectionChanged: (v) {
                    final mode = v.first;
                    prefs.themeMode = mode;
                    ref.invalidate(preferencesServiceProvider);
                    onChanged(mode);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      );
    });
  }
}
