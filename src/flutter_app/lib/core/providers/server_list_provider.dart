import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/server_config.dart' as model;
import '../database/app_database.dart';
import 'database_provider.dart';

class ServerListNotifier extends StateNotifier<List<model.ServerConfig>> {
  final AppDatabase _db;

  ServerListNotifier(this._db) : super([]);

  Future<void> loadServers() async {
    final rows = await _db.select(_db.serverConfigs).get();
    state = rows
        .map((r) => model.ServerConfig(
              id: r.id,
              name: r.name,
              scheme: r.scheme,
              host: r.host,
              token: r.token,
              preferredAuthMethodId: r.preferredAuthMethodId,
            ))
        .toList();
  }

  Future<void> addServer(model.ServerConfig server) async {
    await _db.into(_db.serverConfigs).insert(
          ServerConfigsCompanion.insert(
            id: server.id,
            name: server.name,
            scheme: server.scheme,
            host: server.host,
            token: server.token,
            type: 'manual',
          ),
        );
    await loadServers();
  }

  Future<void> deleteServer(String id) async {
    await (_db.delete(_db.serverConfigs)..where((t) => t.id.equals(id))).go();
    await loadServers();
  }
}

final serverListProvider =
    StateNotifierProvider<ServerListNotifier, List<model.ServerConfig>>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return ServerListNotifier(db);
  },
);
