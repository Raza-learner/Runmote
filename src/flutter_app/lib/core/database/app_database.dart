import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class ServerConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get scheme => text()();
  TextColumn get host => text()();
  TextColumn get token => text()();
  TextColumn? get preferredAuthMethodId => text().nullable()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class GatewaySources extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get scheme => text()();
  TextColumn get host => text()();
  TextColumn get gatewayCredential => text()();
  DateTimeColumn? get gatewayCredentialExpiresAt => dateTime().nullable()();
  TextColumn? get gatewayRemoteMode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class GatewayAgentBindings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get gatewaySourceId => text()();
  TextColumn get agentId => text()();
  TextColumn? get preferredAuthMethodId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionCache extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text()();
  TextColumn? get title => text().nullable()();
  TextColumn? get cwd => text().nullable()();
  IntColumn? get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionSettings extends Table {
  TextColumn get targetId => text()();
  TextColumn? get cwd => text().nullable()();

  @override
  Set<Column> get primaryKey => {targetId};
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get messageJson => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ServerConfigs,
    GatewaySources,
    GatewayAgentBindings,
    SessionCache,
    SessionSettings,
    ChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        await m.createTable(chatMessages);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'acp_remote.sqlite'));
    return NativeDatabase(file);
  });
}
