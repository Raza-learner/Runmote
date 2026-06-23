import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_provider.dart';
import 'database_provider.dart';

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

  SessionListNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final connection = _ref.read(connectionProvider);
      debugPrint('[ACP-SESS] load: channel=${connection.channel != null} agent=${connection.selectedAgentId}');
      if (connection.channel == null) {
        debugPrint('[ACP-SESS] load: channel is null, returning empty');
        state = const AsyncValue.data([]);
        return;
      }

      final notifier = _ref.read(connectionProvider.notifier);
      final db = _ref.read(databaseProvider);
      final selectedAgentId = connection.selectedAgentId;
      final capabilities = connection.capabilities;
      final supportsList = capabilities?.supportsSessionList ?? true;
      debugPrint('[ACP-SESS] load: selected=$selectedAgentId supportsList=$supportsList deleted=${_deletedIds.length}');

      final pairingCode = _cacheDeviceCode(
        connection.pairingCode ?? '',
        selectedAgentId,
      );

      if (!supportsList) {
        debugPrint('[ACP-SESS] load: agent does not support session/list, using local cache');
        final cached = await db.getCachedSessions(pairingCode);
        final sessions = cached.map((s) => AcpSession(
          id: s.id,
          title: s.title,
          cwd: s.cwd,
          updatedAt: s.updatedAt,
        )).where((s) => !_deletedIds.contains(s.id)).toList();
        debugPrint('[ACP-SESS] load: ${sessions.length} cached sessions (${_deletedIds.length} deleted)');
        state = AsyncValue.data(sessions);
        return;
      }

      final completer = Completer<List<AcpSession>>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        debugPrint('[ACP-SESS] load: stream msg id=${msg['id']} expect=$requestId');
        if (msg['id'] == requestId) {
          try {
            final result = msg['result'] as Map<String, dynamic>?;
            if (result != null) {
              final raw = result['sessions'];
              debugPrint('[ACP-SESS] load: got result');
              final sessions =
                  (raw as List<dynamic>?)
                      ?.map((e) => AcpSession.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              debugPrint('[ACP-SESS] load: parsed ${sessions.length}');
              if (!completer.isCompleted) {
                completer.complete(sessions);
              }
            } else {
              debugPrint('[ACP-SESS] load: error: ${msg['error']}');
              if (!completer.isCompleted) {
                completer.complete([]);
              }
            }
          } catch (e, _) {
            debugPrint('[ACP-SESS] load: listener threw: $e');
            if (!completer.isCompleted) {
              completer.complete([]);
            }
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      debugPrint('[ACP-SESS] load: sending session/list id=$requestId');
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
          debugPrint('[ACP-SESS] load: TIMEOUT');
          return [];
        },
      );

      await sub.cancel();

      final sessions = rawSessions
          .where((s) => !_deletedIds.contains(s.id))
          .toList();
      debugPrint('[ACP-SESS] load: got ${sessions.length} (${rawSessions.length} raw, ${_deletedIds.length} deleted)');

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
      debugPrint('[ACP-SESS] load: error $e');
      state = AsyncValue.error(e, st);
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
      debugPrint('[ACP-SESS] create: cwd=$cwd agent=${connection.selectedAgentId}');

      final completer = Completer<AcpSession?>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        debugPrint('[ACP-SESS] create: stream msg id=${msg['id']} expect=$requestId');
        if (msg['id'] == requestId) {
          try {
            final result = msg['result'] as Map<String, dynamic>?;
            if (result != null) {
              final sessionId = result['sessionId'] as String;
              debugPrint('[ACP-SESS] create: got sessionId=$sessionId');
              if (!completer.isCompleted) {
                completer.complete(
                  AcpSession(
                    id: sessionId,
                    cwd: cwd,
                    updatedAt: DateTime.now().millisecondsSinceEpoch / 1000,
                    agentId: connection.selectedAgentId,
                  ),
                );
              }
            } else {
              debugPrint('[ACP-SESS] create: error response: ${msg['error']}');
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            }
          } catch (e, st) {
            debugPrint('[ACP-SESS] create: listener threw: $e\n$st');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      debugPrint('[ACP-SESS] create: sending session/new id=$requestId');
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
          debugPrint('[ACP-SESS] create: TIMEOUT after 5s');
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
