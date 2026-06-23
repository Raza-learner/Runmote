import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart' as db;
import '../../core/models/chat_message.dart';
import '../../core/models/assistant_segment.dart';
import '../../core/providers/connection_provider.dart';
import '../../core/providers/database_provider.dart';

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

  const ChatState({
    this.messages = const [],
    this.configOptions = const [],
    this.currentModel,
    this.currentMode,
  });
}

class ChatNotifier extends StateNotifier<AsyncValue<ChatState>> {
  final Ref _ref;
  final String _sessionId;
  final _uuid = const Uuid();
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _loaded = false;
  final List<ChatMessage> _buffer = [];

  ChatNotifier(this._ref, this._sessionId)
      : super(const AsyncValue.loading()) {
    _listenToRelay();
    _loadMessages();
  }

  void _syncState() {
    state = AsyncValue.data(ChatState(messages: List.of(_buffer)));
  }

  void _syncConfigAndState(List<ConfigOption> configs) {
    final model = configs.where((c) => c.category == 'model').firstOrNull;
    final mode = configs.where((c) => c.category == 'mode').firstOrNull;
    state = AsyncValue.data(ChatState(
      messages: List.of(_buffer),
      configOptions: configs,
      currentModel: model?.currentValue,
      currentMode: mode?.currentValue,
    ));
  }

  Future<void> _loadMessages() async {
    try {
      final db = _ref.read(databaseProvider);
      final rows = await db.getMessages(_sessionId);
      final dbMessages = rows.map(_dbRowToMessage).toList();
      if (_buffer.isNotEmpty) {
        _buffer.insertAll(0, dbMessages);
      } else {
        _buffer.addAll(dbMessages);
      }
    } catch (e) {
      debugPrint('[ACP-CHAT] _loadMessages error: $e');
    }
    _loaded = true;
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
      isStreaming: row.isStreaming == 1,
      createdAt: row.createdAt.toInt(),
    );
  }

  void _listenToRelay() {
    final notifier = _ref.read(connectionProvider.notifier);
    debugPrint('[ACP-CHAT] $_sessionId listening for updates');
    _sub = notifier.messages.listen((msg) {
      final method = msg['method'] as String?;
      final params = msg['params'] as Map<String, dynamic>?;

      if (params != null && params['sessionId'] == _sessionId) {
        if (method == 'session/update') {
          _handleUpdate(params);
        } else if (method == 'session/notification') {
          _handleLegacyNotification(params);
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
    });
  }

  void _handleUpdate(Map<String, dynamic> params) {
    final update = params['update'] as Map<String, dynamic>?;
    if (update == null) return;

    final type = update['sessionUpdate'] as String?;
    final content = update['content'] as Map<String, dynamic>?;
    final text = content?['text'] as String? ?? '';
    debugPrint('[ACP-CHAT] update: type=$type text=${text.length > 60 ? text.substring(0, 60) : text}');

    switch (type) {
      case 'agent_message_chunk':
        _appendOrCreate(text, ChatMessageRole.assistant, update['messageId']);
      case 'user_message_chunk':
        _buffer.add(ChatMessage(
          id: update['messageId'] as String? ?? _uuid.v4(),
          role: ChatMessageRole.user,
          content: text,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
        if (_loaded) _syncState();
      case 'tool_call':
        _addSegment(
          SegmentKind.toolCall,
          update['title'] as String? ?? 'tool call',
          update['toolCallId'] as String? ?? '',
        );
      case 'tool_call_update':
        final status = update['status'] as String?;
        if (status == 'completed') {
          final toolOut = update['content'] as List<dynamic>?;
          final outText = toolOut
                  ?.map((c) => (c as Map)['text'] ?? '')
                  .join('\n') ??
              '';
          final toolId = update['toolCallId'] as String? ?? '';
          for (var i = 0; i < _buffer.length; i++) {
            final m = _buffer[i];
            for (final seg in m.segments) {
              if (seg.kind == SegmentKind.toolCall &&
                  seg.text.contains(toolId)) {
                _buffer[i] = m.copyWith(
                  segments: m.segments
                      .map((s) => s == seg
                          ? s.copyWith(metadata: {'output': outText})
                          : s)
                      .toList(),
                );
                break;
              }
            }
          }
          if (_loaded) _syncState();
        }
      case 'plan':
        _addSegment(
          SegmentKind.plan,
          (update['entries'] as List<dynamic>?)
                  ?.map((e) => (e as Map)['content'] as String? ?? '')
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
      default:
        break;
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
        _appendOrCreate(text, ChatMessageRole.assistant, null);
      }
    }
  }

  void _appendOrCreate(String text, ChatMessageRole role, dynamic msgId) {
    final last = _buffer.isNotEmpty ? _buffer.last : null;
    if (last != null &&
        last.isStreaming &&
        last.role == ChatMessageRole.assistant &&
        role == ChatMessageRole.assistant) {
      _buffer[_buffer.length - 1] = last.copyWith(content: last.content + text);
    } else {
      _buffer.add(ChatMessage(
        id: msgId as String? ?? _uuid.v4(),
        role: role,
        content: text,
        isStreaming: role == ChatMessageRole.assistant,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    if (_loaded) _syncState();
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

  Future<void> sendMessage(String text) async {
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

    await notifier.sendSessionMessage(_sessionId, text);
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
    ChatNotifier, AsyncValue<ChatState>, String>(
  (ref, sessionId) => ChatNotifier(ref, sessionId),
);
