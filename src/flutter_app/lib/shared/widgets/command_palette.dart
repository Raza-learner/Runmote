import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaletteCommand {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onSelect;
  const PaletteCommand({required this.title, required this.subtitle, required this.icon, required this.onSelect});
}

Future<void> showCommandPalette(BuildContext context, WidgetRef ref, List<PaletteCommand> commands) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _CommandPaletteSheet(commands: commands),
  );
}

class _CommandPaletteSheet extends StatefulWidget {
  final List<PaletteCommand> commands;
  const _CommandPaletteSheet({required this.commands});
  @override
  State<_CommandPaletteSheet> createState() => _CommandPaletteSheetState();
}

class _CommandPaletteSheetState extends State<_CommandPaletteSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PaletteCommand> get _filtered {
    if (_query.isEmpty) return widget.commands;
    final q = _query.toLowerCase();
    return widget.commands.where((c) => c.title.toLowerCase().contains(q) || c.subtitle.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Type a command… (Ctrl+K)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No commands found', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      itemBuilder: (ctx, i) {
                        final cmd = filtered[i];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                            child: Icon(cmd.icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          title: Text(cmd.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(cmd.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            cmd.onSelect();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommandPaletteShortcut extends StatelessWidget {
  final Widget child;
  final VoidCallback onOpen;
  const CommandPaletteShortcut({super.key, required this.child, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK): const _OpenPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK): const _OpenPaletteIntent(),
      },
      child: Actions(
        actions: {_OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(onInvoke: (_) { onOpen(); return null; })},
        child: Focus(autofocus: false, child: child),
      ),
    );
  }
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}
