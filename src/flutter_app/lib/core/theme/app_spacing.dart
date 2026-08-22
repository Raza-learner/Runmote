abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double pagePadding = md;
  // Consolidated radii scale: 12 / 16 / 20 (P1.1)
  static const double cardRadius = 16;
  static const double cardRadiusLarge = 20;
  static const double chipRadius = 20;
  static const double inputRadius = 16;
  static const double sheetRadius = 20;

  // Motion
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 320);
}
