import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_provider.dart';
import 'database_provider.dart';
import 'preferences_provider.dart';
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

  void markInactive(String sessionId) {
    _timers[sessionId]?.cancel();
    _timers.remove(sessionId);
    final next = Set<String>.from(state)..remove(sessionId);
    if (_latest == sessionId) _latest = next.isEmpty ? null : next.last;
    state = next;
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

  AcpSession copyWith({String? cwd}) => AcpSession(
    id: id,
    title: title,
    cwd: cwd ?? this.cwd,
    updatedAt: updatedAt,
    agentId: agentId,
  );

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
  int _requestSeq = 0;
  int get _nextRequestId => ++_requestSeq;

  SessionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _listenToMessages();
  }

  void _listenToMessages() {
    final notifier = _ref.read(connectionProvider.notifier);

    _messageSub = notifier.messages.listen((msg) {
      final method = msg['method'] as String?;
      if (method != null && method.startsWith('session/')) {
        _debouncedRefresh();
        return;
      }

      // Passive session-list responses forwarded from relay (no method, just
      // id + result.sessions).  Refresh so the list stays in sync when the
      // agent sends its initial list or after a daemon reconnect.
      final result = msg['result'] as Map<String, dynamic>?;
      if (result != null && result.containsKey('sessions')) {
        _debouncedRefresh();
        return;
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
    if (_isLoading) {
      return;
    }
    _isLoading = true;

    // Preserve existing data while refreshing so the list doesn't flash.
    final currentSessions = state.valueOrNull ?? [];
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

      if (!state.hasValue) {
        state = AsyncValue.data(cachedSessions);
      }

      if (!supportsList) {
        final merged = <String, AcpSession>{};
        for (final s in currentSessions) {
          if (!_deletedIds.contains(s.id)) {
            merged[s.id] = s;
          }
        }
        for (final s in cachedSessions) {
          merged[s.id] = s;
        }
        final sessions = merged.values.toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        state = AsyncValue.data(sessions);
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
              if (!completer.isCompleted) {
                completer.complete([]);
              }
            }
          } catch (e, st) {
            if (!completer.isCompleted) {
              completer.complete([]);
            }
          }
        }
      });

      requestId = _nextRequestId;
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
        onTimeout: () => [],
      );

      await sub.cancel();

      // Merge remote sessions into cached sessions. Prefer remote entries when
      // they exist, because the agent is the source of truth for sessions it
      // knows about. Keep cached-only sessions (e.g. created on this phone).
      final remoteSessions = rawSessions
          .where((s) => !_deletedIds.contains(s.id))
          // Defensive filter: ignore sessions the relay tagged for a different
          // agent. This prevents cross-agent session leakage if the relay ever
          // forwards a mixed list.
          .where((s) => selectedAgentId == null || s.agentId == null || s.agentId == selectedAgentId)
          .toList();

      // Preserve very recent local sessions while refreshing so a newly
      // created session doesn't flicker out before the agent echoes it back.
      final nowSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final recentThreshold = nowSec - 10;
      final merged = <String, AcpSession>{};
      for (final s in currentSessions) {
        if (!_deletedIds.contains(s.id) && s.updatedAt >= recentThreshold) {
          merged[s.id] = s;
        }
      }
      for (final s in cachedSessions) {
        merged[s.id] = s;
      }
      for (final s in remoteSessions) {
        final existing = merged[s.id];
        if (existing != null && s.cwd.isEmpty && existing.cwd.isNotEmpty) {
          // Preserve local cwd when remote omits it (some agents don't
          // echo cwd in session/list). Patch it into the remote entry.
          merged[s.id] = s.copyWith(cwd: existing.cwd);
        } else {
          merged[s.id] = s;
        }
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
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }

  Future<AcpSession?> createSession(String cwd) async {
    try {
      final connection = _ref.read(connectionProvider);
      if (connection.channel == null) {
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
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            }
          } catch (e, st) {
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        }
      });

      requestId = _nextRequestId;
      final prefs = await _ref.read(preferencesServiceProvider.future);
      final mcps = prefs.getMcpServers().map((s) => s.toJson()).toList();
      final payload = {
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'session/new',
        'params': {
          if (connection.selectedAgentId != null)
            'agentId': connection.selectedAgentId,
          'cwd': cwd,
          'mcpServers': mcps,
        },
      };
      notifier.sendRaw(payload);

      final session = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      await sub.cancel();

      if (session != null) {
        final db = _ref.read(databaseProvider);
        final code = _cacheDeviceCode(
          connection.pairingCode ?? '',
          connection.selectedAgentId,
        );
        await db.cacheSession(
          id: session.id,
          deviceCode: code,
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
      'id': _nextRequestId,
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
