import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart' as db;
import '../../core/models/chat_message.dart';
import '../../core/models/assistant_segment.dart';
import '../../core/providers/connection_provider.dart';
import '../../core/providers/database_provider.dart';

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref _ref;
  final String _sessionId;
  final _uuid = const Uuid();
  StreamSubscription<Map<String, dynamic>>? _sub;

  ChatNotifier(this._ref, this._sessionId)
      : super(const AsyncValue.loading()) {
    _loadMessages();
    _listenToRelay();
  }

  Future<void> _loadMessages() async {
    try {
      final db = _ref.read(databaseProvider);
      final rows = await db.getMessages(_sessionId);
      final messages = rows.map(_dbRowToMessage).toList();
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  ChatMessage _dbRowToMessage(db.ChatMessage row) {
    List<AssistantSegment> segments = [];
    if (row.segmentsJson != null && row.segmentsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(row.segmentsJson!) as List<dynamic>;
        segments =
            list.map((e) => AssistantSegment.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return ChatMessage(
      id: row.id,
      role: row.role == 'user' ? ChatMessageRole.user : ChatMessageRole.assistant,
      content: row.content,
      segments: segments,
      isStreaming: row.isStreaming == 1,
      createdAt: row.createdAt.toInt(),
    );
  }

  void _listenToRelay() {
    final notifier = _ref.read(connectionProvider.notifier);
    _sub = notifier.messages.listen((msg) {
      final method = msg['method'] as String?;
      final params = msg['params'] as Map<String, dynamic>?;

      if (method == 'session/notification' && params != null) {
        final msgSessionId = params['sessionId'] as String?;
        if (msgSessionId == _sessionId) {
          _handleNotification(params);
        }
      }
    });
  }

  void _handleNotification(Map<String, dynamic> params) {
    final isStreaming = params['isStreaming'] as bool? ?? false;
    final content = params['content'] as List<dynamic>? ?? [];

    if (!isStreaming) {
      state.whenData((messages) {
        final updated = messages.map((m) {
          return m.isStreaming ? m.copyWith(isStreaming: false) : m;
        }).toList();
        state = AsyncValue.data(updated);
      });
      return;
    }

    for (final block in content) {
      final type = block['type'] as String?;
      final text = block['text'] as String? ?? '';

      if (type == 'text') {
        state.whenData((messages) {
          final lastIdx = messages.length - 1;
          if (lastIdx >= 0 &&
              messages[lastIdx].isStreaming &&
              messages[lastIdx].role == ChatMessageRole.assistant) {
            final updated = messages.map((m) {
              return m.isStreaming ? m.copyWith(content: m.content + text) : m;
            }).toList();
            state = AsyncValue.data(updated);
          } else {
            final newMsg = ChatMessage(
              id: _uuid.v4(),
              role: ChatMessageRole.assistant,
              content: text,
              isStreaming: true,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            );
            state = AsyncValue.data([...messages, newMsg]);
          }
        });
      }
    }
  }

  Future<void> sendMessage(String text) async {
    final notifier = _ref.read(connectionProvider.notifier);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatMessageRole.user,
      content: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state.whenData((messages) {
      state = AsyncValue.data([...messages, userMsg]);
    });

    final db = _ref.read(databaseProvider);
    await db.saveMessage(
      id: userMsg.id,
      sessionId: _sessionId,
      role: 'user',
      content: text,
      isStreaming: false,
    );

    await notifier.sendSessionMessage(_sessionId, text);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<
    ChatNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, sessionId) => ChatNotifier(ref, sessionId),
);
