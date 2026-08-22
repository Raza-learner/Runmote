import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData buildFlexTheme({
  required FlexScheme scheme,
  required Brightness brightness,
}) {
  const sub = FlexSubThemesData(
    // Consolidated radii 12/16/20 (P1.1)
    defaultRadius: 12,
    cardRadius: 16,
    textButtonRadius: 12,
    filledButtonRadius: 12,
    elevatedButtonRadius: 12,
    outlinedButtonRadius: 12,
    inputDecoratorRadius: 16,
    chipRadius: 8,
    dialogRadius: 16,
    bottomSheetRadius: 20,
    snackBarRadius: 12,
    popupMenuRadius: 12,
    searchBarRadius: 16,
    fabRadius: 16,
    interactionEffects: true,
    tintedDisabledControls: true,
    useMaterial3Typography: true,
  );
  if (brightness == Brightness.light) {
    return FlexThemeData.light(
      scheme: scheme,
      subThemesData: sub,
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 7,
      scaffoldBackground: const Color(0xFFF9F7F2), // Soft Cream background
      surface: const Color(0xFFFDFCFB),
    );
  }
  return FlexThemeData.dark(
    scheme: scheme,
    subThemesData: sub.copyWith(
      cardElevation: 1,
      blendOnLevel: 12,
      blendOnColors: false,
    ),
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
    blendLevel: 2, // P3.1: single accent, reduce blue tint
    darkIsTrueBlack: false,
    appBarBackground: const Color(0xFF141417),
    surface: const Color(0xFF141417),
    scaffoldBackground: const Color(0xFF0A0A0B), // true dev black
    tooltipsMatchBackground: true,
  );
}
