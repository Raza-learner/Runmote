import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_provider.dart';
import 'database_provider.dart';

class AcpSession {
  final String id;
  final String? title;
  final String cwd;
  final double updatedAt;

  const AcpSession({
    required this.id,
    this.title,
    required this.cwd,
    required this.updatedAt,
  });

  factory AcpSession.fromJson(Map<String, dynamic> json) {
    return AcpSession(
      id: json['id'] as String,
      title: json['title'] as String?,
      cwd: json['cwd'] as String? ?? '',
      updatedAt: (json['updatedAt'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SessionListNotifier extends StateNotifier<AsyncValue<List<AcpSession>>> {
  final Ref _ref;

  SessionListNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final connection = _ref.read(connectionProvider);
      if (connection.channel == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final notifier = _ref.read(connectionProvider.notifier);
      final db = _ref.read(databaseProvider);
      final pairingCode = connection.pairingCode ?? '';

      final completer = Completer<List<AcpSession>>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        if (msg['id'] == requestId) {
          final result = msg['result'] as Map<String, dynamic>?;
          if (result != null) {
            final sessions = (result['sessions'] as List<dynamic>?)
                    ?.map((e) => AcpSession.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
            completer.complete(sessions);
          } else {
            completer.complete([]);
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      notifier.sendRaw({
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'session/list',
        'params': {},
      });

      final sessions = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );

      await sub.cancel();

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
    }
  }

  Future<AcpSession?> createSession(String cwd) async {
    try {
      final connection = _ref.read(connectionProvider);
      if (connection.channel == null) return null;

      final notifier = _ref.read(connectionProvider.notifier);

      final completer = Completer<AcpSession?>();
      int? requestId;
      StreamSubscription<Map<String, dynamic>>? sub;

      sub = notifier.messages.listen((msg) {
        if (msg['id'] == requestId) {
          final result = msg['result'] as Map<String, dynamic>?;
          if (result != null) {
            final sessionId = result['sessionId'] as String;
            completer.complete(AcpSession(
              id: sessionId,
              cwd: cwd,
              updatedAt: DateTime.now().millisecondsSinceEpoch.toDouble(),
            ));
          } else {
            completer.complete(null);
          }
        }
      });

      requestId = DateTime.now().millisecondsSinceEpoch;
      notifier.sendRaw({
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'session/new',
        'params': {'cwd': cwd},
      });

      final session = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      await sub.cancel();

      if (session != null) {
        final db = _ref.read(databaseProvider);
        await db.cacheSession(
          id: session.id,
          deviceCode: connection.pairingCode ?? '',
          title: session.title,
          cwd: session.cwd,
          updatedAt: session.updatedAt,
        );
        await loadSessions();
      }

      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSession(String id) async {
    final db = _ref.read(databaseProvider);
    await db.removeCachedSession(id);
    await loadSessions();
  }
}

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, AsyncValue<List<AcpSession>>>(
        (ref) {
  return SessionListNotifier(ref);
});
