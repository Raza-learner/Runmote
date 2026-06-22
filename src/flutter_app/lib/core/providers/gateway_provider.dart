import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../models/gateway_source.dart';
import '../models/gateway_agent_binding.dart';
import '../database/app_database.dart' hide GatewaySource, GatewayAgentBinding;
import 'database_provider.dart';

class GatewayListNotifier extends StateNotifier<List<GatewaySource>> {
  final AppDatabase _db;

  GatewayListNotifier(this._db) : super([]);

  Future<void> loadGateways() async {
    final rows = await _db.select(_db.gatewaySources).get();
    state = rows
        .map((r) => GatewaySource(
              id: r.id,
              name: r.name,
              scheme: r.scheme,
              host: r.host,
              gatewayCredential: r.gatewayCredential,
              gatewayCredentialExpiresAt: r.gatewayCredentialExpiresAt,
              gatewayRemoteMode: r.gatewayRemoteMode,
            ))
        .toList();
  }

  Future<void> addGateway(GatewaySource gateway) async {
    await _db.into(_db.gatewaySources).insert(
          GatewaySourcesCompanion.insert(
            id: gateway.id,
            name: gateway.name,
            scheme: gateway.scheme,
            host: gateway.host,
            gatewayCredential: gateway.gatewayCredential,
            gatewayCredentialExpiresAt:
                Value(gateway.gatewayCredentialExpiresAt),
            gatewayRemoteMode: Value(gateway.gatewayRemoteMode),
          ),
        );
    await loadGateways();
  }

  Future<void> deleteGateway(String id) async {
    await (_db.delete(_db.gatewaySources)..where((t) => t.id.equals(id))).go();
    await loadGateways();
  }
}

final gatewayListProvider =
    StateNotifierProvider<GatewayListNotifier, List<GatewaySource>>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return GatewayListNotifier(db);
  },
);

class GatewayAgentsNotifier extends StateNotifier<List<GatewayAgentBinding>> {
  final AppDatabase _db;

  GatewayAgentsNotifier(this._db) : super([]);

  Future<void> loadAgents(String gatewayId) async {
    final query = _db.select(_db.gatewayAgentBindings)
      ..where((t) => t.gatewaySourceId.equals(gatewayId));
    final results = await query.get();
    state = results
        .map((r) => GatewayAgentBinding(
              id: r.id,
              name: r.name,
              gatewaySourceId: r.gatewaySourceId,
              agentId: r.agentId,
              preferredAuthMethodId: r.preferredAuthMethodId,
            ))
        .toList();
  }
}

final gatewayAgentsProvider = StateNotifierProvider.family<
    GatewayAgentsNotifier,
    List<GatewayAgentBinding>,
    String>(
  (ref, gatewayId) {
    final db = ref.watch(databaseProvider);
    return GatewayAgentsNotifier(db);
  },
);
