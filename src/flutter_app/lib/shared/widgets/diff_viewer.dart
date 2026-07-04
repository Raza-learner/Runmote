import 'package:flutter/material.dart';

class DiffViewer extends StatelessWidget {
  final String oldText;
  final String newText;

  const DiffViewer({
    super.key,
    required this.oldText,
    required this.newText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffLines = _computeDiff(oldText, newText);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in diffLines)
              _DiffLine(
                line: line.text,
                type: line.type,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.5,
                ),
                bgColors: _bgColors(theme),
              ),
          ],
        ),
      ),
    );
  }

  _DiffBgColors _bgColors(ThemeData theme) => _DiffBgColors(
        addition: theme.colorScheme.primary.withValues(alpha: 0.12),
        deletion: theme.colorScheme.error.withValues(alpha: 0.12),
        additionAccent: theme.colorScheme.primary.withValues(alpha: 0.25),
        deletionAccent: theme.colorScheme.error.withValues(alpha: 0.25),
      );

  List<_DiffLineData> _computeDiff(String oldText, String newText) {
    final oldLines = oldText.split('\n');
    final newLines = newText.split('\n');

    final List<_DiffLineData> result = [];

    final lcs = _lcsIndices(oldLines, newLines);
    int oldIdx = 0, newIdx = 0;

    for (final match in lcs) {
      while (oldIdx < match.oldIdx) {
        result.add(_DiffLineData('- ${oldLines[oldIdx]}', _DiffType.deletion));
        oldIdx++;
      }
      while (newIdx < match.newIdx) {
        result.add(_DiffLineData('+ ${newLines[newIdx]}', _DiffType.addition));
        newIdx++;
      }
      result.add(_DiffLineData('  ${oldLines[oldIdx]}', _DiffType.unchanged));
      oldIdx++;
      newIdx++;
    }
    while (oldIdx < oldLines.length) {
      result.add(_DiffLineData('- ${oldLines[oldIdx]}', _DiffType.deletion));
      oldIdx++;
    }
    while (newIdx < newLines.length) {
      result.add(_DiffLineData('+ ${newLines[newIdx]}', _DiffType.addition));
      newIdx++;
    }

    if (result.isEmpty) {
      result.add(const _DiffLineData('  (no changes)', _DiffType.unchanged));
    }
    return result;
  }

  List<_LcsMatch> _lcsIndices(List<String> a, List<String> b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    final matches = <_LcsMatch>[];
    int i = m, j = n;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        matches.add(_LcsMatch(i - 1, j - 1));
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    return matches.reversed.toList();
  }
}

enum _DiffType { addition, deletion, unchanged }

class _DiffLineData {
  final String text;
  final _DiffType type;
  const _DiffLineData(this.text, this.type);
}

class _LcsMatch {
  final int oldIdx;
  final int newIdx;
  const _LcsMatch(this.oldIdx, this.newIdx);
}

class _DiffBgColors {
  final Color addition;
  final Color deletion;
  final Color additionAccent;
  final Color deletionAccent;
  const _DiffBgColors({
    required this.addition,
    required this.deletion,
    required this.additionAccent,
    required this.deletionAccent,
  });
}

class _DiffLine extends StatelessWidget {
  final String line;
  final _DiffType type;
  final TextStyle? style;
  final _DiffBgColors bgColors;

  const _DiffLine({
    required this.line,
    required this.type,
    required this.style,
    required this.bgColors,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Color? fg;
    switch (type) {
      case _DiffType.addition:
        bg = bgColors.addition;
        fg = Colors.green.shade700;
      case _DiffType.deletion:
        bg = bgColors.deletion;
        fg = Colors.red.shade700;
      case _DiffType.unchanged:
    }

    return Container(
      width: double.maxFinite,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Text(
        line,
        style: style?.copyWith(
          color: fg ?? style?.color,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
