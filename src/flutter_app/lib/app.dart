import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/models/server_config.dart' as model;
import 'core/providers/preferences_provider.dart';
import 'features/servers/server_list_screen.dart';
import 'features/servers/add_server_screen.dart';
import 'features/servers/pair_gateway_screen.dart';
import 'features/servers/gateway_list_screen.dart';
import 'features/servers/gateway_agents_screen.dart';
import 'features/sessions/session_list_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ServerListScreen(),
    ),
    GoRoute(
      path: '/servers/add',
      builder: (context, state) => const AddServerScreen(),
    ),
    GoRoute(
      path: '/servers/edit',
      builder: (context, state) => AddServerScreen(
        server: state.extra as model.ServerConfig?,
      ),
    ),
    GoRoute(
      path: '/gateways/pair',
      builder: (context, state) => const PairGatewayScreen(),
    ),
    GoRoute(
      path: '/gateways',
      builder: (context, state) => const GatewayListScreen(),
    ),
    GoRoute(
      path: '/gateways/:id/agents',
      builder: (context, state) => GatewayAgentsScreen(
        gatewayId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/sessions/:serverId',
      builder: (context, state) => SessionListScreen(
        serverId: state.pathParameters['serverId']!,
        serverName: state.extra as String? ?? 'Agent',
      ),
    ),
    GoRoute(
      path: '/chat/:sessionId',
      builder: (context, state) => ChatScreen(
        sessionId: state.pathParameters['sessionId']!,
        title: state.extra as String? ?? 'Chat',
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class AcpRemoteApp extends ConsumerWidget {
  const AcpRemoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(preferencesServiceProvider).when(
      data: (prefs) => switch (prefs.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      loading: () => ThemeMode.system,
      error: (_, _) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'ACP Remote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
