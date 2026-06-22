import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../models/session_summary.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

class SessionListNotifier extends StateNotifier<List<SessionSummary>> {
  final AppDatabase _db;
  final String _serverId;

  SessionListNotifier(this._db, this._serverId) : super([]);

  Future<void> loadSessions() async {
    final rows = await (_db.select(_db.sessionCache)
          ..where((t) => t.serverId.equals(_serverId))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    state = rows
        .map((r) => SessionSummary(
              id: r.id,
              title: r.title,
              cwd: r.cwd,
              updatedAt: r.updatedAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(r.updatedAt!)
                  : null,
            ))
        .toList();
  }

  Future<SessionSummary> createSession({String? title}) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final session = SessionSummary(
      id: id,
      title: title ?? 'Session ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      updatedAt: now,
    );
    await _db.into(_db.sessionCache).insert(
          SessionCacheCompanion.insert(
            id: id,
            serverId: _serverId,
            title: Value(session.title),
            updatedAt: Value(now.millisecondsSinceEpoch),
          ),
        );
    await loadSessions();
    return session;
  }

  Future<void> deleteSession(String id) async {
    await (_db.delete(_db.sessionCache)..where((t) => t.id.equals(id))).go();
    await loadSessions();
  }

  Future<void> renameSession(String id, String title) async {
    await (_db.update(_db.sessionCache)..where((t) => t.id.equals(id)))
        .write(SessionCacheCompanion(title: Value(title)));
    await loadSessions();
  }
}

final sessionListProvider =
    StateNotifierProvider.family<SessionListNotifier, List<SessionSummary>, String>(
  (ref, serverId) {
    final db = ref.watch(databaseProvider);
    return SessionListNotifier(db, serverId);
  },
);
