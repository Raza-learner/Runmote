import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:acp_remote/core/database/app_database.dart';
import 'package:acp_remote/core/models/connection_state.dart';
import 'package:acp_remote/core/providers/connection_provider.dart';
import 'package:acp_remote/core/providers/database_provider.dart';
import 'package:acp_remote/core/providers/session_list_provider.dart';
import 'package:acp_remote/features/sessions/view/widgets/session_card.dart';

class _FakeSink implements WebSocketSink {
  @override
  void add(dynamic data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<dynamic> stream) => Future.value();
  @override
  Future<dynamic> get done => Future.value();
  @override
  Future<void> close([int? code, String? reason]) => Future.value();
}

class _FakeChannel with StreamChannelMixin<dynamic> implements WebSocketChannel {
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;
  @override
  String? get protocol => null;
  @override
  Future<void> get ready => Future.value();
  @override
  WebSocketSink get sink => _FakeSink();
  @override
  Stream<dynamic> get stream => const Stream.empty();
}

class _MockConn extends ConnectionNotifier {
  final _msgCtrl = StreamController<Map<String, dynamic>>.broadcast();

  _MockConn(super.ref) {
    state = AcpConnection(
      channel: _FakeChannel(),
      state: const AcpConnectionState.connected(),
      paired: true,
      daemonConnected: true,
    );
  }

  @override
  Stream<Map<String, dynamic>> get messages => _msgCtrl.stream;

  @override
  void sendRaw(Map<String, dynamic> message) {
    final rid = message['id'] as int;
    _msgCtrl.add({'id': rid, 'result': {'sessions': []}});
  }

  void respond(Map<String, dynamic> result) {
    _msgCtrl.add({'id': 0, 'result': result});
  }

  @override
  void dispose() {
    _msgCtrl.close();
    super.dispose();
  }
}

void main() {
  group('Provider + Widget integration', () {
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.test();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('SessionListNotifier feeds data to SessionCard list',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
          connectionProvider.overrideWith((ref) => _MockConn(ref)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, child) {
                final sessions = ref.watch(sessionListProvider);
                return sessions.when(
                  loading: () => const Text('Loading'),
                  error: (e, _) => Text('Error: $e'),
                  data: (list) => ListView(
                    children: list
                        .map((s) => SessionCard(
                              title: s.title,
                              cwd: s.cwd,
                              timeAgo: 'now',
                              isActive: false,
                              onTap: () {},
                              onDelete: () {},
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ));

      await tester.pump();

      // Should show loading initially, then data (empty list from mock)
      expect(find.byType(SessionCard), findsNothing);
    });

    testWidgets('SessionCard appears after sessions are loaded',
        (WidgetTester tester) async {
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWith((ref) => db),
        connectionProvider.overrideWith((ref) => _MockConn(ref)),
      ]);

      // Seed the provider with a session
      final notifier = container.read(sessionListProvider.notifier);
      notifier.state = AsyncValue.data([
        AcpSession(id: 's-1', cwd: '/home', updatedAt: 1000, title: 'Test Session'),
      ]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final sessions = ref.watch(sessionListProvider);
                  return sessions.when(
                    loading: () => const Text('Loading'),
                    error: (e, _) => Text('Error: $e'),
                    data: (list) => ListView(
                      children: list
                          .map((s) => SessionCard(
                                title: s.title,
                                cwd: s.cwd,
                                timeAgo: 'now',
                                isActive: false,
                                onTap: () {},
                                onDelete: () {},
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Test Session'), findsOneWidget);
      expect(find.text('/home'), findsOneWidget);

      container.dispose();
    });
  });
}
