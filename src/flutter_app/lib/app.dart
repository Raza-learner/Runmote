import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/preferences_provider.dart';
import 'core/providers/connection_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(connectionProvider.notifier).retryNow();
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'system';
    ref.read(themeModeStateProvider.notifier).state = _parseThemeMode(mode);

    final schemeName = prefs.getString('flex_scheme');
    if (schemeName != null) {
      final scheme = FlexScheme.values.where((s) => s.name == schemeName).firstOrNull;
      if (scheme != null) {
        ref.read(flexSchemeProvider.notifier).state = scheme;
      }
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
    final scheme = ref.watch(flexSchemeProvider);
    return MaterialApp.router(
      title: 'Runmote',
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: buildFlexTheme(scheme: scheme, brightness: Brightness.light),
      darkTheme: buildFlexTheme(scheme: scheme, brightness: Brightness.dark),
      themeMode: themeMode,
    );
  }
}
