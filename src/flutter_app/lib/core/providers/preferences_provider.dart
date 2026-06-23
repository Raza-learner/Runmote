import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

final defaultCwdProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(preferencesServiceProvider.future);
  return prefs.getDefaultCwd();
});

final themeModeProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(preferencesServiceProvider.future);
  return prefs.getThemeMode();
});

final themeModeStateProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final pairingCodeProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(preferencesServiceProvider.future);
  return prefs.getPairingCode();
});

final clearAllDataProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(preferencesServiceProvider.future);
  final db = ref.read(databaseProvider);
  await db.clearAll();
  await prefs.clearAll();
});
