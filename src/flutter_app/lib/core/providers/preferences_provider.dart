import 'dart:convert';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mcp_server.dart';
import '../services/preferences_service.dart';
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

final flexSchemeProvider = StateProvider<FlexScheme>((ref) {
  return FlexScheme.shadViolet;
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

class McpServersNotifier extends StateNotifier<List<McpServer>> {
  McpServersNotifier() : super([]);

  Future<void> load(PreferencesService prefs) async {
    state = prefs.getMcpServers();
  }

  Future<void> add(PreferencesService prefs, McpServer server) async {
    state = [...state, server];
    await prefs.setMcpServers(state);
  }

  Future<void> update(PreferencesService prefs, int index, McpServer server) async {
    final list = [...state];
    list[index] = server;
    state = list;
    await prefs.setMcpServers(state);
  }

  Future<void> remove(PreferencesService prefs, int index) async {
    final list = [...state];
    list.removeAt(index);
    state = list;
    await prefs.setMcpServers(state);
  }
}

final mcpServersProvider =
    StateNotifierProvider<McpServersNotifier, List<McpServer>>((ref) {
  return McpServersNotifier();
});
