import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/models/chat_message.dart';
import '../../../core/models/assistant_segment.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/session_list_provider.dart';
import '../../../core/models/connection_state.dart';

class ConfigOption {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String currentValue;
  final List<ConfigOptionValue> options;

  const ConfigOption({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.currentValue,
    required this.options,
  });

  factory ConfigOption.fromJson(Map<String, dynamic> json) {
    return ConfigOption(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['id'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      currentValue: json['currentValue'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) =>
                  ConfigOptionValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ConfigOptionValue {
  final String value;
  final String name;
  final String? description;

  const ConfigOptionValue({
    required this.value,
    required this.name,
    this.description,
  });

  factory ConfigOptionValue.fromJson(Map<String, dynamic> json) {
    return ConfigOptionValue(
      value: json['value'] as String,
      name: json['name'] as String? ?? json['value'] as String,
      description: json['description'] as String?,
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final List<ConfigOption> configOptions;
  final String? currentModel;
  final String? currentMode;
  final bool isBusy;

  const ChatState({
    this.messages = const [],
    this.configOptions = const [],
    this.currentModel,
    this.currentMode,
    this.isBusy = false,
  });
}

class ChatNotifier extends StateNotifier<AsyncValue<ChatState>> {
  final Ref _ref;
  final String _sessionId;
  final String _cwd;
  final _uuid = const Uuid();
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _loaded = false;
  final List<ChatMessage> _buffer = [];
  final Set<int> _pendingIds = {};
  int? _loadPendingId;
  String? _timeoutMessageId;

  ChatNotifier(this._ref, this._sessionId, this._cwd)
      : super(const AsyncValue.loading()) {
    _listenToRelay();
    _loadSessionFromAgent();
    loadMessages();
  }

  void _loadSessionFromAgent() {
    final connection = _ref.read(connectionProvider);
    final supportsLoad = connection.capabilities?.supportsLoadSession ?? true;
    if (!supportsLoad) {
      return;
    }
    final notifier = _ref.read(connectionProvider.notifier);
    final id = notifier.loadSession(_sessionId, _cwd);
    _pendingIds.add(id);
    _loadPendingId = id;
  }

  bool get _isBusy =>
      _pendingIds.isNotEmpty ||
      _buffer.any((m) => m.isStreaming);

  void _syncState() {
    state = AsyncValue.data(ChatState(
      messages: List.of(_buffer),
      isBusy: _isBusy,
    ));
  }

  void _syncConfigAndState(List<ConfigOption> configs) {
    final model = configs.where((c) => c.category == 'model').firstOrNull;
    final mode = configs.where((c) => c.category == 'mode').firstOrNull;
    state = AsyncValue.data(ChatState(
      messages: List.of(_buffer),
      configOptions: configs,
      currentModel: model?.currentValue,
      currentMode: mode?.currentValue,
      isBusy: _isBusy,
    ));
  }

  Future<void> loadMessages() async {
    try {
      final db = _ref.read(databaseProvider);
      final rows = await db.getRecentMessages(_sessionId, limit: 5);
      final dbMessages = rows.reversed.map(_dbRowToMessage).toList();
      if (_buffer.isNotEmpty) {
        _buffer.insertAll(0, dbMessages);
      } else {
        _buffer.addAll(dbMessages);
      }
    } catch (e) {
      debugPrint('[ACP-CHAT] _loadMessages error: $e');
    }
    _loaded = true;
    if (_loadPendingId != null) {
      Future.delayed(const Duration(seconds: 10), () {
        if (_loadPendingId != null && _pendingIds.contains(_loadPendingId)) {
          _pendingIds.remove(_loadPendingId);
          _loadPendingId = null;
          _syncState();
        }
      });
      return;
    }
    _syncState();
  }

  void _setConfigOptions(List<ConfigOption> configs) {
    if (_loaded) {
      _syncConfigAndState(configs);
    }
  }

  ChatMessage _dbRowToMessage(db.ChatMessage row) {
    List<AssistantSegment> segments = [];
    if (row.segmentsJson != null && row.segmentsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(row.segmentsJson!) as List<dynamic>;
        segments = list
            .map((e) =>
                AssistantSegment.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return ChatMessage(
      id: row.id,
      role:
          row.role == 'user' ? ChatMessageRole.user : ChatMessageRole.assistant,
      content: row.content,
      segments: segments,
      isStreaming: false,
      createdAt: row.createdAt.toInt(),
    );
  }

  void _populateFromLoad(Map<String, dynamic> result) {
    try {
      final rawMessages = result['messages'] as List<dynamic>;
      final maxMessages = rawMessages.length > 50 ? rawMessages.sublist(rawMessages.length - 50) : rawMessages;
      var added = false;
      for (final raw in maxMessages) {
        if (raw is! Map<String, dynamic>) continue;
        final id = (raw['id'] as String?) ?? _uuid.v4();
        if (_buffer.any((m) => m.id == id)) continue;

        final roleStr = raw['role'] as String? ?? 'assistant';
        if (roleStr != 'user' && roleStr != 'assistant') continue;
        final role = roleStr == 'user'
            ? ChatMessageRole.user
            : ChatMessageRole.assistant;
        final content = raw['content'] as String? ?? '';

        List<AssistantSegment> segments = [];
        if (raw['segments'] is List) {
          for (final seg in raw['segments'] as List<dynamic>) {
            if (seg is Map<String, dynamic>) {
              try {
                segments.add(AssistantSegment.fromJson(seg));
              } catch (_) {}
            }
          }
        }

        _buffer.add(ChatMessage(
          id: id,
          role: role,
          content: content,
          segments: segments,
          isStreaming: false,
          createdAt: (raw['createdAt'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch,
        ));
        added = true;
      }

      if (added) {
        _saveMessagesToDb();
        if (_loaded) _syncState();
      }
    } catch (e) {
      debugPrint('[ACP-CHAT] error parsing load response: $e');
    }
  }

  Future<void> _saveMessagesToDb() async {
    try {
      final db = _ref.read(databaseProvider);
      for (final m in _buffer) {
        if (m.role == ChatMessageRole.user) continue;
        await db.saveMessage(
          id: m.id,
          sessionId: _sessionId,
          role: 'assistant',
          content: m.content,
          isStreaming: false,
          createdAt: m.createdAt,
        );
      }
    } catch (e) {
      debugPrint('[ACP-CHAT] error saving to DB: $e');
    }
  }

  void _listenToRelay() {
    final notifier = _ref.read(connectionProvider.notifier);
    _sub = notifier.messages.listen(
      (msg) {
        final method = msg['method'] as String?;
        final params = msg['params'] as Map<String, dynamic>?;

        if (params != null && params['sessionId'] == _sessionId) {
          if (method == 'session/update') {
            _handleUpdate(params);
          } else if (method == 'session/notification') {
            _handleLegacyNotification(params);
          }
        }

        // Detect JSON-RPC response to a pending request (prompt/load done)
        final msgId = msg['id'];
        if (method == null && msgId != null && _pendingIds.remove(msgId)) {
          final wasLoad = msgId == _loadPendingId;
          if (wasLoad) {
            _loadPendingId = null;
            final result = msg['result'] as Map<String, dynamic>?;
            if (result != null && result['messages'] is List) {
              _populateFromLoad(result);
            }
          }

          // If the agent says the session doesn't exist, remove it locally
          // so the user sees why their message got no response.
          if (!wasLoad) {
            final error = msg['error'] as Map<String, dynamic>?;
            final errorMsg = error?['message'] as String? ?? '';
            if (errorMsg.contains('session not found')) {
              _buffer.add(ChatMessage(
                id: _uuid.v4(),
                role: ChatMessageRole.assistant,
                content: 'This session no longer exists on the agent side.',
                isStreaming: false,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ));
              _ref.read(sessionListProvider.notifier).deleteSession(_sessionId);
              _finalizeStreaming();
              _ref.read(activeSessionsProvider.notifier).markInactive(_sessionId);
              return;
            }
          }

          // Remove the "waiting" message once the agent actually responds.
          if (_timeoutMessageId != null) {
            _buffer.removeWhere((m) => m.id == _timeoutMessageId);
            _timeoutMessageId = null;
          }

          _finalizeStreaming();
          _ref.read(activeSessionsProvider.notifier).markInactive(_sessionId);
          if (!wasLoad) {
            _ref.read(sessionListProvider.notifier).loadSessions();
          }
        }

        // Capture configOptions from session/new response
        final result = msg['result'] as Map<String, dynamic>?;
        if (result != null && result['configOptions'] is List) {
          final configs = (result['configOptions'] as List<dynamic>)
              .map((e) => ConfigOption.fromJson(e as Map<String, dynamic>))
              .toList();
          if (configs.isNotEmpty) {
            _setConfigOptions(configs);
          }
        }
      },
      onError: (error) {
        debugPrint('[ACP-CHAT] stream error: $error');
      },
      onDone: () {
        debugPrint('[ACP-CHAT] stream closed');
      },
    );
  }

  String _extractText(dynamic content) {
    if (content is String) return content;
    if (content is Map) return (content['text'] as String?) ?? '';
    if (content is List) {
      return content.map((c) {
        if (c is Map) return (c['text'] as String?) ?? '';
        return c.toString();
      }).join();
    }
    return '';
  }

  void _handleUpdate(Map<String, dynamic> params) {
    final update = params['update'] as Map<String, dynamic>?;
    if (update == null) return;

    final type = update['sessionUpdate'] as String?;
    final text = _extractText(update['content']);
    final msgId = update['messageId'] as String?;


    switch (type) {
      case 'user_message_chunk':
        _finalizeStreaming();
        _upsertMessage(text, ChatMessageRole.user, msgId);
      case 'agent_message_chunk':
        _upsertMessage(text, ChatMessageRole.assistant, msgId);
      case 'agent_thought_chunk':
        _addThoughtChunk(text);
      case 'tool_call':
        _ensureAssistantMessage();
        _addSegment(
          SegmentKind.toolCall,
          update['title'] as String? ?? 'tool call',
          update['toolCallId'] as String? ?? '',
        );
      case 'tool_call_update':
        final toolOut = update['content'] as List<dynamic>?;
        final outText = toolOut
                ?.map((c) => (c as Map<String, dynamic>)['text'] ?? '')
                .join('\n') ??
            '';
        final toolId = update['toolCallId'] as String? ?? '';
        final toolStatus = update['status'] as String?;
        _updateToolOutput(toolId, outText, toolStatus);
      case 'plan':
        _ensureAssistantMessage();
        _addSegment(
          SegmentKind.plan,
          (update['entries'] as List<dynamic>?)
                  ?.map((e) => (e as Map<String, dynamic>)['content'] as String? ?? '')
                  .join('\n') ??
              'plan',
          '',
        );
      case 'config_option_update':
        final configs = update['configOptions'] as List<dynamic>?;
        if (configs != null) {
          _setConfigOptions(
            configs
                .map((e) => ConfigOption.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        }
      case 'usage_update':
        break;
      default:
        debugPrint('[ACP-CHAT] unhandled update type: $type');
        break;
    }
  }

  void _finalizeStreaming() {
    for (var i = 0; i < _buffer.length; i++) {
      if (_buffer[i].isStreaming) {
        _buffer[i] = _buffer[i].copyWith(isStreaming: false);
      }
    }
    if (_loaded) _syncState();
  }

  void _upsertMessage(String text, ChatMessageRole role, String? msgId) {
    if (msgId != null) {
      for (var i = 0; i < _buffer.length; i++) {
        if (_buffer[i].id == msgId) {
          final existing = _buffer[i].content;
          // Some agents send cumulative/full-message chunks instead of deltas.
          final newContent = text.startsWith(existing) ? text : existing + text;
          _buffer[i] = _buffer[i].copyWith(content: newContent);
          if (_loaded) _syncState();
          return;
        }
      }
    }
    // If no msgId and role is assistant, append to last streaming assistant message
    if (role == ChatMessageRole.assistant && _buffer.isNotEmpty) {
      final last = _buffer.last;
      if (last.role == ChatMessageRole.assistant && last.isStreaming) {
        final newContent = last.content + text;
        _buffer[_buffer.length - 1] = last.copyWith(content: newContent);
        if (_loaded) _syncState();
        return;
      }
    }
    _buffer.add(ChatMessage(
      id: msgId ?? _uuid.v4(),
      role: role,
      content: text,
      isStreaming: role == ChatMessageRole.assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    if (_loaded) _syncState();
  }

  void _addThoughtChunk(String text) {
    _ensureAssistantMessage();
    final last = _buffer.last;
    final existing = last.segments
        .where((s) => s.kind == SegmentKind.thought)
        .toList();
    if (existing.isNotEmpty) {
      final found = existing.last;
      _buffer[_buffer.length - 1] = last.copyWith(
        segments: last.segments
            .map((s) => s == found
                ? s.copyWith(text: s.text + text)
                : s)
            .toList(),
      );
    } else {
      _buffer[_buffer.length - 1] = last.copyWith(
        segments: [
          ...last.segments,
          AssistantSegment(
            id: _uuid.v4(),
            kind: SegmentKind.thought,
            text: text,
          ),
        ],
      );
    }
    if (_loaded) _syncState();
  }

  void _ensureAssistantMessage() {
    if (_buffer.isEmpty || _buffer.last.role != ChatMessageRole.assistant) {
      _buffer.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatMessageRole.assistant,
        content: '',
        isStreaming: true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        segments: [],
      ));
    }
  }

  void _updateToolOutput(String toolId, String outText, String? status) {
    for (var i = 0; i < _buffer.length; i++) {
      final m = _buffer[i];
      for (final seg in m.segments) {
        if (seg.kind == SegmentKind.toolCall && seg.id == toolId) {
          final newMeta = Map<String, dynamic>.from(seg.metadata);
          if (outText.isNotEmpty) {
            newMeta['output'] = (newMeta['output'] ?? '') + outText;
          }
          if (status != null) {
            newMeta['status'] = status;
          }
          _buffer[i] = m.copyWith(
            segments: m.segments
                .map((s) => s == seg ? s.copyWith(metadata: newMeta) : s)
                .toList(),
          );
          if (_loaded) _syncState();
          return;
        }
      }
    }
  }

  void _handleLegacyNotification(Map<String, dynamic> params) {
    final isStreaming = params['isStreaming'] as bool? ?? false;
    final content = params['content'] as List<dynamic>? ?? [];

    if (!isStreaming) {
      for (var i = 0; i < _buffer.length; i++) {
        if (_buffer[i].isStreaming) {
          _buffer[i] = _buffer[i].copyWith(isStreaming: false);
        }
      }
      _syncState();
      return;
    }

    for (final block in content) {
      final type = block['type'] as String?;
      final text = block['text'] as String? ?? '';
      if (type == 'text') {
        _upsertMessage(text, ChatMessageRole.assistant, null);
      }
    }
  }

  void _addSegment(SegmentKind kind, String text, String toolId) {
    if (_buffer.isEmpty) return;
    final last = _buffer.last;
    final seg = AssistantSegment(
      id: toolId.isNotEmpty ? toolId : _uuid.v4(),
      kind: kind,
      text: text,
    );
    _buffer[_buffer.length - 1] = last.copyWith(segments: [...last.segments, seg]);
    if (_loaded) _syncState();
  }

  Future<void> sendMessage(String text, {List<Map<String, dynamic>>? extra}) async {
    final connection = _ref.read(connectionProvider);
    final notifier = _ref.read(connectionProvider.notifier);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatMessageRole.user,
      content: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _buffer.add(userMsg);
    _syncState();

    final db = _ref.read(databaseProvider);
    await db.saveMessage(
      id: userMsg.id,
      sessionId: _sessionId,
      role: 'user',
      content: text,
      isStreaming: false,
    );

    if (connection.channel == null || connection.state is! Connected) {
      _buffer.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatMessageRole.assistant,
        content: 'Not connected to agent. Please check the relay/daemon.',
        isStreaming: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      _finalizeStreaming();
      return;
    }

    final id = notifier.sendSessionMessage(_sessionId, text, extra: extra);
    _pendingIds.add(id);

    // After 30s, show a waiting message but keep the pending ID alive so
    // a late response is still processed (agent may be busy executing a tool).
    _timeoutMessageId = null;
    Future.delayed(const Duration(seconds: 30), () {
      if (!_pendingIds.contains(id)) return;
      final msg = ChatMessage(
        id: _uuid.v4(),
        role: ChatMessageRole.assistant,
        content: 'Agent is working... (may be busy executing a tool)',
        isStreaming: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _timeoutMessageId = msg.id;
      _buffer.add(msg);
      _syncState();
    });
  }

  Future<void> setConfigOption(String configId, String value) async {
    final notifier = _ref.read(connectionProvider.notifier);
    final connection = _ref.read(connectionProvider);

    notifier.sendRaw({
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': 'session/set_config_option',
      'params': {
        if (connection.selectedAgentId != null)
          'agentId': connection.selectedAgentId,
        'sessionId': _sessionId,
        'configId': configId,
        'value': value,
      },
    });

    final current = state.valueOrNull;
    if (current != null) {
      final updatedConfigs = current.configOptions.map((c) {
        if (c.id == configId) {
          return ConfigOption(
            id: c.id,
            name: c.name,
            description: c.description,
            category: c.category,
            currentValue: value,
            options: c.options,
          );
        }
        return c;
      }).toList();
      _setConfigOptions(updatedConfigs);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<
    ChatNotifier, AsyncValue<ChatState>, (String, String)>(
  (ref, key) {
    final (sessionId, cwd) = key;
    return ChatNotifier(ref, sessionId, cwd);
  },
);
