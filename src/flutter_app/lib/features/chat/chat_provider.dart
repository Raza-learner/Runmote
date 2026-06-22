import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/assistant_segment.dart';
import '../../core/providers/connection_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/database/app_database.dart' hide ChatMessage;

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, List<ChatMessage>, String>(
  (ref, sessionId) => ChatNotifier(ref, sessionId),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final String _sessionId;

  ChatNotifier(this._ref, this._sessionId) : super([]) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    try {
      final db = _ref.read(databaseProvider);
      final rows = await (db.select(db.chatMessages)
            ..where((t) => t.sessionId.equals(_sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
          .get();
      state = rows
          .map((r) => ChatMessage.fromJson(
              jsonDecode(r.messageJson) as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> _saveMessage(ChatMessage msg) async {
    try {
      final db = _ref.read(databaseProvider);
      await db.into(db.chatMessages).insert(
            ChatMessagesCompanion.insert(
              id: msg.id,
              sessionId: _sessionId,
              messageJson: jsonEncode(msg.toJson()),
              createdAt: msg.createdAt,
            ),
          );
    } catch (_) {}
  }

  Future<void> _updateMessage(String id, ChatMessage msg) async {
    try {
      final db = _ref.read(databaseProvider);
      await (db.update(db.chatMessages)..where((t) => t.id.equals(id)))
          .write(ChatMessagesCompanion(
            messageJson: Value(jsonEncode(msg.toJson())),
          ));
    } catch (_) {}
  }

  void sendMessage(String text) {
    final msg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatMessageRole.user,
      content: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [...state, msg];
    _saveMessage(msg);

    try {
      _ref.read(connectionProvider.notifier).sendRelaySessionMessage(_sessionId, text);
    } catch (_) {}
  }

  void handleRelayMessage(Map<String, dynamic> params) {
    final content = params['content'] as String? ?? '';
    final rawSegments = params['segments'] as List<dynamic>? ?? [];
    final isStreaming = params['isStreaming'] as bool? ?? false;

    final segments = rawSegments
        .map((s) => AssistantSegment.fromJson(s as Map<String, dynamic>))
        .toList();

    final lastMsg = state.isNotEmpty ? state.last : null;
    if (lastMsg != null && lastMsg.role == ChatMessageRole.assistant && lastMsg.isStreaming) {
      final updated = lastMsg.copyWith(
        content: content,
        segments: segments,
        isStreaming: isStreaming,
      );
      state = [
        ...state.take(state.length - 1),
        updated,
      ];
      _updateMessage(lastMsg.id, updated);
    } else {
      final msg = ChatMessage(
        id: const Uuid().v4(),
        role: ChatMessageRole.assistant,
        content: content,
        segments: segments,
        isStreaming: isStreaming,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      state = [...state, msg];
      if (!isStreaming) _saveMessage(msg);
    }
  }

  void addLocalMessage(ChatMessage message) {
    state = [...state, message];
    _saveMessage(message);
  }

  void updateMessage(int index, ChatMessage message) {
    final list = [...state];
    list[index] = message;
    state = list;
  }

  void removeMessageAt(int index) {
    if (index < 0 || index >= state.length) return;
    final msg = state[index];
    final list = [...state];
    list.removeAt(index);
    state = list;
    try {
      final db = _ref.read(databaseProvider);
      (db.delete(db.chatMessages)..where((t) => t.id.equals(msg.id))).go();
    } catch (_) {}
  }

  Future<void> clear() async {
    state = [];
    try {
      final db = _ref.read(databaseProvider);
      await (db.delete(db.chatMessages)
            ..where((t) => t.sessionId.equals(_sessionId)))
          .go();
    } catch (_) {}
  }
}
