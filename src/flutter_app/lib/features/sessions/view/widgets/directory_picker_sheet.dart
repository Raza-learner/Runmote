import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/connection_provider.dart';
import '../../../../core/theme/app_spacing.dart';

class DirectoryPickerSheet extends ConsumerStatefulWidget {
  final String initialPath;
  final ValueChanged<String> onSelected;

  const DirectoryPickerSheet({
    super.key,
    required this.initialPath,
    required this.onSelected,
  });

  @override
  ConsumerState<DirectoryPickerSheet> createState() =>
      _DirectoryPickerSheetState();
}

class _DirectoryEntry {
  final String name;
  final String path;
  final String type;
  final int size;
  final bool isSymlink;

  const _DirectoryEntry({
    required this.name,
    required this.path,
    required this.type,
    this.size = 0,
    this.isSymlink = false,
  });

  factory _DirectoryEntry.fromJson(Map<String, dynamic> json) {
    return _DirectoryEntry(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      type: json['type'] as String? ?? 'file',
      size: json['size'] as int? ?? 0,
      isSymlink: json['isSymlink'] as bool? ?? false,
    );
  }
}

class _DirectoryPickerSheetState extends ConsumerState<DirectoryPickerSheet> {
  final _history = <String>[];
  late String _currentPath;
  var _entries = <_DirectoryEntry>[];
  var _loading = true;
  String? _error;
  var _showHidden = false;
  var _isAtDrives = false;
  int? _pendingRequestId;
  StreamSubscription<Map<String, dynamic>>? _sub;
  static const _initialSize = 0.55;
  static const _expandedSize = 0.95;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _loadDirectory();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _loadDirectory() {
    setState(() {
      _loading = true;
      _error = null;
      _isAtDrives = false;
    });
    _sub?.cancel();
    final notifier = ref.read(connectionProvider.notifier);
    _pendingRequestId = notifier.listDirectory(
      _currentPath,
      showHidden: _showHidden,
    );
    _sub = notifier.messages.listen((msg) {
      if (msg['id'] == _pendingRequestId) {
        _sub?.cancel();
        final result = msg['result'] as Map<String, dynamic>?;
        if (result != null) {
          final raw = result['entries'] as List<dynamic>? ?? [];
          setState(() {
            _entries = raw
                .map((e) => _DirectoryEntry.fromJson(e as Map<String, dynamic>))
                .toList();
            _loading = false;
          });
        } else {
          final error = msg['error'] as Map<String, dynamic>?;
          setState(() {
            _error = error?['message'] as String? ?? 'Failed to list directory';
            _loading = false;
          });
        }
      }
    });
  }

  void _navigateInto(String path) {
    _history.add(_currentPath);
    _currentPath = path;
    _loadDirectory();
  }

  void _navigateUp() {
    if (_history.isNotEmpty) {
      _currentPath = _history.removeLast();
      _loadDirectory();
    }
  }

  void _loadDrives() {
    setState(() {
      _loading = true;
      _error = null;
      _isAtDrives = true;
    });
    _sub?.cancel();
    final notifier = ref.read(connectionProvider.notifier);
    _pendingRequestId = notifier.listDrives();
    _sub = notifier.messages.listen((msg) {
      if (msg['id'] == _pendingRequestId) {
        _sub?.cancel();
        final result = msg['result'] as Map<String, dynamic>?;
        if (result != null) {
          final raw = result['entries'] as List<dynamic>? ?? [];
          setState(() {
            _entries = raw
                .map((e) => _DirectoryEntry.fromJson(e as Map<String, dynamic>))
                .toList();
            _loading = false;
          });
        } else {
          final error = msg['error'] as Map<String, dynamic>?;
          setState(() {
            _error = error?['message'] as String? ?? 'Failed to list drives';
            _loading = false;
          });
        }
      }
    });
  }

  void _toggleHidden() {
    setState(() => _showHidden = !_showHidden);
    _loadDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: _initialSize,
      minChildSize: 0.4,
      maxChildSize: _expandedSize,
      snap: true,
      snapSizes: const [_initialSize, _expandedSize],
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildBreadcrumb(),
            _buildActionBar(),
            const Divider(height: 1),
            Expanded(
              child: _buildContent(scrollController),
            ),
            _buildBottomButton(),
          ],
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: Row(
        children: [
          Text(
            'Choose directory',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showHidden ? Icons.visibility : Icons.visibility_off,
              size: 20,
            ),
            onPressed: _toggleHidden,
            tooltip: _showHidden ? 'Hide hidden files' : 'Show hidden files',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          InkWell(
            onTap: !_isAtDrives
                ? () {
                    _history.add(_currentPath);
                    _loadDrives();
                  }
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(Icons.home, size: 16, color: theme.colorScheme.primary),
            ),
          ),
          if (_isAtDrives) ...[
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Drives',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            ..._buildBreadcrumbParts(theme),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbParts(ThemeData theme) {
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();
    final widgets = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      widgets.add(Icon(
        Icons.chevron_right,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ));
      widgets.add(InkWell(
        onTap: i < parts.length - 1
            ? () {
                final target = _joinPath(parts, i + 1);
                _history.add(_currentPath);
                _currentPath = target;
                _loadDirectory();
              }
            : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            parts[i],
            style: theme.textTheme.bodySmall?.copyWith(
              color: i == parts.length - 1
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.primary,
              fontWeight: i == parts.length - 1
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildActionBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: Row(
        children: [
          if (_history.isNotEmpty && !_isAtDrives)
            TextButton.icon(
              onPressed: _navigateUp,
              icon: const Icon(Icons.arrow_upward, size: 16),
              label: const Text('Up'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          const Spacer(),
          Text(
            '${_entries.where((e) => e.type == 'directory').length} dirs',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_entries.where((e) => e.type == 'file').length} files',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _isAtDrives ? _loadDrives : _loadDirectory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Empty directory',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 52),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isDir = entry.type == 'directory';
        return InkWell(
          onTap: isDir ? () => _navigateInto(entry.path) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  isDir
                      ? Icons.folder_outlined
                      : Icons.insert_drive_file_outlined,
                  size: 22,
                  color: isDir
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isDir ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isDir && entry.size > 0)
                        Text(
                          _formatSize(entry.size),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (entry.isSymlink)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.shortcut,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (isDir)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAtDrives ? null : () => widget.onSelected(_currentPath),
            icon: Icon(_isAtDrives ? Icons.info_outline : Icons.add),
            label: Text(_isAtDrives
                ? 'Select a directory from the list'
                : 'Open session in ${_currentPath.split('/').lastOrNull ?? '/'}'),
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _joinPath(List<String> parts, int endIndex) {
    final joined = parts.take(endIndex).join('/');
    if (parts[0].endsWith(':')) return joined;
    return '/$joined';
  }
}
