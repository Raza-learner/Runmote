import 'package:flutter/material.dart';

/// Centralized motion tokens (P2.1) — ensures consistent durations / curves.
/// Calm B2B motion: quick for micro-interactions, gentle for page transitions.
abstract final class AppMotion {
  // Durations
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);
  static const emphasis = Duration(milliseconds: 400);

  // Curves — M3 motion easing
  static const easeOut = Curves.easeOutCubic;
  static const easeIn = Curves.easeInCubic;
  static const easeEmphasized = Curves.easeOutExpo;
  static const spring = Curves.easeOutBack;

  // Helpers
  static Duration get adaptiveFast =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations
          ? Duration.zero
          : fast;
}
