import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/pair/pair_screen.dart';
import 'features/agents/agent_list_screen.dart';
import 'features/sessions/session_list_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PairScreen(),
    ),
    GoRoute(
      path: '/agents',
      builder: (context, state) => const AgentListScreen(),
    ),
    GoRoute(
      path: '/sessions',
      builder: (context, state) => const SessionListScreen(),
    ),
    GoRoute(
      path: '/chat/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return ChatScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ACP Remote',
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
