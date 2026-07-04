import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:acp_remote/core/database/app_database.dart';
import 'package:acp_remote/core/models/chat_message.dart';
import 'package:acp_remote/core/models/connection_state.dart';
import 'package:acp_remote/core/providers/connection_provider.dart';
import 'package:acp_remote/core/providers/database_provider.dart';
import 'package:acp_remote/core/providers/session_list_provider.dart';
import 'package:acp_remote/features/chat/viewmodel/chat_provider.dart';

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

class MockConnectionNotifier extends ConnectionNotifier {
  final _messageCtrl = StreamController<Map<String, dynamic>>.broadcast();
  int _counter = 100;

  MockConnectionNotifier(super.ref) {
    state = AcpConnection(
      channel: _FakeChannel(),
      state: const AcpConnectionState.connected(),
      paired: true,
      daemonConnected: true,
    );
  }

  @override
  Stream<Map<String, dynamic>> get messages => _messageCtrl.stream;

  @override
  int sendSessionMessage(
    String sessionId,
    String text, {
    List<Map<String, dynamic>>? extra,
  }) {
    return ++_counter;
  }

  @override
  Future<int> loadSession(String sessionId, String cwd) async {
    return ++_counter;
  }

  @override
  void sendRaw(Map<String, dynamic> message) {}

  void injectMessage(Map<String, dynamic> msg) {
    _messageCtrl.add(msg);
  }

  @override
  void dispose() {
    _messageCtrl.close();
    super.dispose();
  }
}

void main() {
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.test();
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [
      databaseProvider.overrideWith((ref) => db),
      connectionProvider.overrideWith((ref) {
        return MockConnectionNotifier(ref);
      }),
    ]);
  }

  group('ChatNotifier', () {
    test('load messages and transition to data', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);

      final chat = container.read(chatProvider(('test-session', '/home')));

      // Initial state is loading
      expect(chat, isA<AsyncLoading<ChatState>>());

      // Wait for loadMessages() to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(chatProvider(('test-session', '/home')));
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull!.messages, isEmpty);

      container.dispose();
    });

    test('sendMessage adds user message and isBusy', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);
      final notifier = container.read(
        chatProvider(('test-session', '/home')).notifier,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.sendMessage('hello');

      final state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.messages.length, 1);
      expect(state.valueOrNull!.messages.first.content, 'hello');
      expect(state.valueOrNull!.messages.first.role, ChatMessageRole.user);
      expect(state.valueOrNull!.isBusy, isFalse);

      container.dispose();
    });

    test('setConfigOption updates config options', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);
      final notifier = container.read(
        chatProvider(('test-session', '/home')).notifier,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final mock = container.read(connectionProvider.notifier)
          as MockConnectionNotifier;
      mock.injectMessage({
        'result': {
          'configOptions': [
            {
              'id': 'model',
              'name': 'Model',
              'category': 'model',
              'currentValue': 'gpt-4',
              'options': [
                {'value': 'gpt-4', 'name': 'GPT-4'},
              ],
            },
          ],
        },
      });

      await Future.delayed(Duration.zero);

      await notifier.setConfigOption('model', 'gpt-3.5');

      final state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.configOptions.length, 1);
      expect(state.valueOrNull!.configOptions.first.currentValue, 'gpt-3.5');
      expect(state.valueOrNull!.currentModel, 'gpt-3.5');

      container.dispose();
    });

    test('stream update appends assistant content', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);
      container.read(chatProvider(('test-session', '/home')));

      await Future.delayed(const Duration(milliseconds: 100));

      final mock = container.read(connectionProvider.notifier)
          as MockConnectionNotifier;

      mock.injectMessage({
        'method': 'session/update',
        'params': {
          'sessionId': 'test-session',
          'update': {
            'sessionUpdate': 'agent_message_chunk',
            'content': 'Hello from agent',
            'messageId': 'msg-1',
          },
        },
      });

      await Future.delayed(Duration.zero);

      final state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.messages.length, 1);
      expect(state.valueOrNull!.messages.first.content, 'Hello from agent');
      expect(
        state.valueOrNull!.messages.first.role,
        ChatMessageRole.assistant,
      );

      container.dispose();
    });

    test('respondToPermission clears permission request', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);
      final notifier = container.read(
        chatProvider(('test-session', '/home')).notifier,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final mock = container.read(connectionProvider.notifier)
          as MockConnectionNotifier;
      mock.injectMessage({
        'method': 'session/request_permission',
        'id': 42,
        'params': {
          'sessionId': 'test-session',
          'toolCall': {
            'title': 'Read file',
            'kind': 'read_file',
            'content': [],
          },
          'options': [
            {
              'optionId': 'allow_once',
              'name': 'Allow once',
              'kind': 'allow_once',
            },
            {'optionId': 'deny', 'name': 'Deny', 'kind': 'deny'},
          ],
        },
      });

      await Future.delayed(Duration.zero);

      var state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.permissionRequest, isNotNull);

      notifier.respondToPermission('allow_once');

      state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.permissionRequest, isNull);

      container.dispose();
    });

    test('dismissPermission clears permission request', () async {
      final container = createContainer();
      container.read(activeSessionsProvider);
      final notifier = container.read(
        chatProvider(('test-session', '/home')).notifier,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final mock = container.read(connectionProvider.notifier)
          as MockConnectionNotifier;
      mock.injectMessage({
        'method': 'session/request_permission',
        'id': 43,
        'params': {
          'sessionId': 'test-session',
          'toolCall': {
            'title': 'Execute',
            'kind': 'bash',
            'content': [],
          },
          'options': [
            {'optionId': 'allow_once', 'kind': 'allow_once'},
          ],
        },
      });

      await Future.delayed(Duration.zero);

      notifier.dismissPermission();

      final state = container.read(chatProvider(('test-session', '/home')));
      expect(state.valueOrNull!.permissionRequest, isNull);

      container.dispose();
    });
  });
}
