import 'package:flutter/material.dart';

class AccentOption {
  final String name;
  final Color color;
  const AccentOption(this.name, this.color);
}

abstract final class AppColors {
  static const online = Color(0xFF4CAF50);
  static const offline = Color(0xFF9E9E9E);
  static const connecting = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);

  static const surfaceDark = Color(0xFF121212);
  static const surfaceContainerDark = Color(0xFF1E1E1E);

  static const glassLight = Color(0xCCFFFFFF);
  static const glassDark = Color(0xCC1E1E1E);

  static const accentOptions = [
    AccentOption('Indigo', Colors.indigo),
    AccentOption('Teal', Colors.teal),
    AccentOption('Blue', Colors.blue),
    AccentOption('Purple', Colors.purple),
    AccentOption('Pink', Colors.pink),
    AccentOption('Orange', Colors.orange),
    AccentOption('Cyan', Colors.cyan),
    AccentOption('Green', Colors.green),
  ];
}
