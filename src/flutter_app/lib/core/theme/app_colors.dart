import 'package:flutter/material.dart';

abstract final class AppColors {
  static const online = Color(0xFF22C55E);
  static const offline = Color(0xFF9E9E9E);
  static const connecting = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const daemonOffline = Color(0xFFE65100);

  static const glassLight = Color(0xCCFFFFFF);
  static const glassDark = Color(0xCC2C2C2C);

  // Semantic tokens (P1.1 + P2.1)
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF6366F1);
  static const brandGradientStart = Color(0xFF6366F1);
  static const brandGradientEnd = Color(0xFFA855F7);

  // Surface tiers for dark-first dev tooling
  static const surfaceDark = Color(0xFF0F172A);
  static const surfaceDarkElevated = Color(0xFF1E293B);
  static const surfaceLight = Color(0xFFFDFCFB);
  static const surfaceLightElevated = Color(0xFFFFFFFF);
}
