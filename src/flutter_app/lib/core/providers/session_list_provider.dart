import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_provider.dart';
import 'database_provider.dart';
import '../models/connection_state.dart';

class ActiveSessionsNotifier extends StateNotifier<Set<String>> {
  final Map<String, Timer> _timers = {};
  String? _latest;

  ActiveSessionsNotifier() : super(const {});

  String? get latestSessionId => _latest;

  void markActive(String sessionId) {
    _timers[sessionId]?.cancel();
    _latest = sessionId;
    state = {...state, sessionId};
    _timers[sessionId] = Timer(const Duration(seconds: 5), () {
      final next = Set<String>.from(state)..remove(sessionId);
      _timers.remove(sessionId);
      state = next;
    });
  }

  void clear() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _latest = null;
    state = const {};
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}

final activeSessionsProvider =
    StateNotifierProvider<ActiveSessionsNotifier, Set<String>>((ref) {
  return ActiveSessionsNotifier();
});

class AcpSession {
  final String id;
  final String? title;
  final String cwd;
  final double updatedAt;
  final String? agentId;

  const AcpSession({
    required this.id,
    this.title,
    required this.cwd,
    required this.updatedAt,
    this.agentId,
  });

  factory AcpSession.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['sessionId'];
    final timestamp = json['updatedAt'] ?? json['createdAt'];

    return AcpSession(
      id: id as String,
      title: (json['title'] ?? json['name']) as String?,
      cwd: json['cwd'] as String? ?? '',
      updatedAt: _secondsTimestamp(timestamp),
      agentId: json['agentId'] as String?,
    );
  }

  static double _secondsTimestamp(dynamic value) {
    if (value is num) {
      final ts = value.toDouble();
      if (ts <= 0) return 0;
      return ts > 9999999999 ? ts / 1000 : ts;
    }
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch / 1000.0;
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }
}

class SessionListNotifier extends StateNotifier<AsyncValue<List<AcpSession>>> {
  final Ref _ref;
  final _deletedIds = <String>{};
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  ProviderSubscription<AcpConnection>? _connectionSub;
  Timer? _debounceTimer;
  bool _wasConnected = false;
  bool _isLoading = false;

  SessionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _listenToMessages();
  }

  void _listenToMessages() {
    final notifier = _ref.read(connectionProvider.notifier);

    _messageSub = notifier.messages.listen((msg) {
      final method = msg['method'] as String?;
      if (method != null && method.startsWith('session/')) {
        _debouncedRefresh();
      }

      // Track actively streaming sessions
      if (method == 'session/update' || method == 'session/notification') {
        final params = msg['params'] as Map<String, dynamic>?;
        final sessionId = params?['sessionId'] as String?;
        if (sessionId != null) {
          _ref.read(activeSessionsProvider.notifier).markActive(sessionId);
        }
      }
    });

    _connectionSub = _ref.listen<AcpConnection>(
      connectionProvider,
      (previous, next) {
        final isConnected = next.state is Connected;
        if (isConnected && !_wasConnected) {
          _debouncedRefresh();
        }
        _wasConnected = isConnected;
      },
    );
  }

  void _debouncedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        loadSessions();
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _connectionSub?.close();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> loadSessions() async {
    if (_isLoading) return;
    _isLoading = true;

    // Preserve existing data while refreshing so the list doesn't flash.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final connection = _ref.read(connectionProvider);
      if (connection.channel == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final notifier = _ref.read(connectionProvider.notifier);
      final db = _ref.read(databaseProvider);
      final selectedAgentId = connection.selectedAgentId;
      final capabilities = connection.capabilities;
      final supportsList = capabilities?.supportsSessionList ?? true;

      final pairingCode = _cacheDeviceCode(
        connection.pairingCode ?? '',
        selectedAgentId,
      );

      // Always show cached sessions first so the list is never empty
      // while waiting for the agent response.
      final cachedRows = await db.getCachedSessions(pairingCode);
      final cachedSessions = cachedRows
          .map((s) => AcpSession(
                id: s.id,
                title: s.title,
                cwd: s.cwd,
                updatedAt: s.updatedAt,
              ))
          .where((s) => !_deletedIds.contains(s.id))
          .toList();
      state = AsyncValue.data(cachedSessions);

      if (!supportsList) {
        return;
      }

      final completer = Completer<List<AcpSession>>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        if (msg['id'] == requestId) {
          try {
            final result = msg['result'] as Map<String, dynamic>?;
            if (result != null) {
              final raw = result['sessions'];
              final sessions = (raw as List<dynamic>?)
                      ?.map((e) => AcpSession.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              if (!completer.isCompleted) {
                completer.complete(sessions);
              }
            } else {
              debugPrint('[ACP-SESS] load error: ${msg['error']}');
              if (!completer.isCompleted) {
                completer.complete([]);
              }
            }
          } catch (e, _) {
            debugPrint('[ACP-SESS] load listener error: $e');
            if (!completer.isCompleted) {
              completer.complete([]);
            }
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      final params = <String, dynamic>{};
      if (selectedAgentId != null) {
        params['agentId'] = selectedAgentId;
      }
      notifier.sendRaw({
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'session/list',
        'params': params,
      });

      final rawSessions = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[ACP-SESS] load TIMEOUT');
          return [];
        },
      );

      await sub.cancel();

      // Merge remote sessions into cached sessions. Prefer remote entries when
      // they exist, because the agent is the source of truth for sessions it
      // knows about. Keep cached-only sessions (e.g. created on this phone).
      final remoteSessions = rawSessions
          .where((s) => !_deletedIds.contains(s.id))
          .toList();
      final merged = <String, AcpSession>{};
      for (final s in cachedSessions) {
        merged[s.id] = s;
      }
      for (final s in remoteSessions) {
        merged[s.id] = s;
      }
      final sessions = merged.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      for (final session in sessions) {
        await db.cacheSession(
          id: session.id,
          deviceCode: pairingCode,
          title: session.title,
          cwd: session.cwd,
          updatedAt: session.updatedAt,
        );
      }

      state = AsyncValue.data(sessions);
    } catch (e, st) {
      debugPrint('[ACP-SESS] load error: $e\n$st');
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }

  Future<AcpSession?> createSession(String cwd) async {
    try {
      final connection = _ref.read(connectionProvider);
      if (connection.channel == null) {
        debugPrint('[ACP-SESS] create: channel is null');
        return null;
      }

      final notifier = _ref.read(connectionProvider.notifier);

      final completer = Completer<AcpSession?>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        if (msg['id'] == requestId) {
          try {
            final result = msg['result'] as Map<String, dynamic>?;
            if (result != null) {
              final sessionId = result['sessionId'] as String;
              final title = (result['title'] ?? result['name']) as String?;
              if (!completer.isCompleted) {
                completer.complete(
                  AcpSession(
                    id: sessionId,
                    title: title,
                    cwd: cwd,
                    updatedAt: DateTime.now().millisecondsSinceEpoch / 1000,
                    agentId: connection.selectedAgentId,
                  ),
                );
              }
            } else {
              debugPrint('[ACP-SESS] create error: ${msg['error']}');
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            }
          } catch (e, st) {
            debugPrint('[ACP-SESS] create listener error: $e\n$st');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      notifier.sendRaw({
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'session/new',
        'params': {
          if (connection.selectedAgentId != null)
            'agentId': connection.selectedAgentId,
          'cwd': cwd,
          'mcpServers': <String>[],
        },
      });

      final session = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[ACP-SESS] create TIMEOUT after 5s');
          return null;
        },
      );

      await sub.cancel();

      if (session != null) {
        final db = _ref.read(databaseProvider);
        await db.cacheSession(
          id: session.id,
          deviceCode: _cacheDeviceCode(
            connection.pairingCode ?? '',
            connection.selectedAgentId,
          ),
          title: session.title,
          cwd: session.cwd,
          updatedAt: session.updatedAt,
        );
        state.whenData((sessions) {
          state = AsyncValue.data([...sessions, session]);
        });
      }

      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSession(String id) async {
    _deletedIds.add(id);
    final db = _ref.read(databaseProvider);
    await db.removeCachedSession(id);
    state.whenData((sessions) {
      state = AsyncValue.data(sessions.where((s) => s.id != id).toList());
    });
  }

  Future<void> deleteSessionRemote(String id) async {
    final notifier = _ref.read(connectionProvider.notifier);
    final connection = _ref.read(connectionProvider);
    notifier.sendRaw({
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': 'session/delete',
      'params': {
        if (connection.selectedAgentId != null)
          'agentId': connection.selectedAgentId,
        'sessionId': id,
      },
    });
  }
}

String _cacheDeviceCode(String pairingCode, String? agentId) {
  if (agentId == null || agentId.isEmpty) return pairingCode;
  return '$pairingCode:$agentId';
}

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, AsyncValue<List<AcpSession>>>((
      ref,
    ) {
      return SessionListNotifier(ref);
    });
