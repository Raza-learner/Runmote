import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/preferences_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'system';
    final accent = prefs.getInt('accent_color');
    ref.read(themeModeStateProvider.notifier).state = _parseThemeMode(mode);
    if (accent != null) {
      ref.read(accentColorProvider.notifier).state = Color(accent);
    }
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeStateProvider);
    final accentColor = ref.watch(accentColorProvider);
    return MaterialApp.router(
      title: 'ACP Remote',
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(seed: accentColor),
      darkTheme: buildDarkTheme(seed: accentColor),
      themeMode: themeMode,
    );
  }
}
