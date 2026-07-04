import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData buildFlexTheme({
  required FlexScheme scheme,
  required Brightness brightness,
}) {
  const sub = FlexSubThemesData(
    defaultRadius: 14,
    cardRadius: 16,
    textButtonRadius: 14,
    filledButtonRadius: 14,
    elevatedButtonRadius: 14,
    outlinedButtonRadius: 14,
    inputDecoratorRadius: 16,
    chipRadius: 8,
    dialogRadius: 20,
    bottomSheetRadius: 24,
    snackBarRadius: 12,
    popupMenuRadius: 14,
    searchBarRadius: 16,
    fabRadius: 28,
  );
  if (brightness == Brightness.light) {
    return FlexThemeData.light(
      scheme: scheme,
      subThemesData: sub,
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    );
  }
  return FlexThemeData.dark(
    scheme: scheme,
    subThemesData: sub,
  );
}
