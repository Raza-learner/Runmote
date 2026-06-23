import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _mono = 'monospace';

  static TextStyle monoSmall(BuildContext context) => TextStyle(
    fontFamily: _mono,
    fontSize: 12,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle monoMedium(BuildContext context) => TextStyle(
    fontFamily: _mono,
    fontSize: 14,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
