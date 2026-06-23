import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/connection_state.dart';
import '../models/agent_info.dart';
import '../models/agent_capabilities.dart';
import 'database_provider.dart';

class AcpAgent {
  final String id;
  final String name;
  final String version;
  final bool online;

  const AcpAgent({
    required this.id,
    required this.name,
    this.version = '',
    this.online = false,
  });

  factory AcpAgent.fromJson(Map<String, dynamic> json) {
    return AcpAgent(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? json['id'] as String,
      version: json['version'] as String? ?? '',
      online: json['online'] as bool? ?? true,
    );
  }

  AgentInfo toAgentInfo() => AgentInfo(name: name, version: version);
}

class AcpConnection {
  final WebSocketChannel? channel;
  final AcpConnectionState state;
  final String? pairingCode;
  final String? relayUrl;
  final String? daemonId;
  final List<AcpAgent> agents;
  final String? selectedAgentId;
  final AgentInfo? agentInfo;
  final AgentCapabilities? capabilities;
  final bool paired;
  final String? error;

  const AcpConnection({
    this.channel,
    this.state = const AcpConnectionState.disconnected(),
    this.pairingCode,
    this.relayUrl,
    this.daemonId,
    this.agents = const [],
    this.selectedAgentId,
    this.agentInfo,
    this.capabilities,
    this.paired = false,
    this.error,
  });

  AcpAgent? get selectedAgent {
    for (final agent in agents) {
      if (agent.id == selectedAgentId) return agent;
    }
    return agents.isNotEmpty ? agents.first : null;
  }

  AcpConnection copyWith({
    WebSocketChannel? channel,
    AcpConnectionState? state,
    String? pairingCode,
    String? relayUrl,
    String? daemonId,
    List<AcpAgent>? agents,
    String? selectedAgentId,
    AgentInfo? agentInfo,
    AgentCapabilities? capabilities,
    bool? paired,
    String? error,
    bool clearChannel = false,
    bool clearSelectedAgent = false,
    bool clearAgentInfo = false,
    bool clearCapabilities = false,
  }) {
    return AcpConnection(
      channel: clearChannel ? null : channel ?? this.channel,
      state: state ?? this.state,
      pairingCode: pairingCode ?? this.pairingCode,
      relayUrl: relayUrl ?? this.relayUrl,
      daemonId: daemonId ?? this.daemonId,
      agents: agents ?? this.agents,
      selectedAgentId: clearSelectedAgent
          ? null
          : selectedAgentId ?? this.selectedAgentId,
      agentInfo: clearAgentInfo ? null : agentInfo ?? this.agentInfo,
      capabilities: clearCapabilities
          ? null
          : capabilities ?? this.capabilities,
      paired: paired ?? this.paired,
      error: error ?? this.error,
    );
  }
}

class ConnectionNotifier extends StateNotifier<AcpConnection> {
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  int? _initId;
  final Ref _ref;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  int _msgId = 0;

  ConnectionNotifier(this._ref) : super(const AcpConnection());

  int get _nextId => ++_msgId;

  Future<void> connect(String code, {String? relayUrl}) async {
    if (state.state case AcpConnectionState()
        when state.state is Connected || state.state is Connecting) {
      return;
    }

    final url = relayUrl ?? state.relayUrl ?? 'ws://localhost:8000';
    debugPrint('[ACP] connect() called with code=$code relayUrl=$url');

    state = state.copyWith(
      state: const AcpConnectionState.connecting(),
      pairingCode: code,
      relayUrl: url,
      paired: false,
      error: null,
    );

    try {
      final uri = Uri.parse('$url/app');
      debugPrint('[ACP] connecting WebSocket to $uri');
      final channel = WebSocketChannel.connect(uri);

      await channel.ready;
      debugPrint('[ACP] WebSocket connected!');

      state = state.copyWith(channel: channel);
      _reconnectAttempts = 0;

      // Send auth/pair with the pairing code
      final pairCompleter = Completer<void>();
      final pairId = _nextId;
      debugPrint('[ACP] sending auth/pair id=$pairId');
      sendRaw({
        'jsonrpc': '2.0',
        'id': pairId,
        'method': 'auth/pair',
        'params': {'code': code},
      });

      _sub = channel.stream.listen(
        (data) => _handleMessage(data, pairId, pairCompleter),
        onError: (e) => _onDisconnected('Connection error: $e'),
        onDone: () => _onDisconnected('Connection closed'),
        cancelOnError: false,
      );

      // Wait for auth response (5s timeout)
      debugPrint('[ACP] waiting for auth/pair response...');
      await pairCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Pairing timed out'),
      );
      debugPrint('[ACP] auth/pair succeeded!');

      state = state.copyWith(
        state: const AcpConnectionState.connected(),
        paired: true,
      );

      // Save pairing code
      final p = await _ref.read(preferencesServiceProvider.future);
      await p.setPairingCode(code);

      debugPrint('[ACP] sending agent/list');
      sendRaw({
        'jsonrpc': '2.0',
        'id': _nextId,
        'method': 'agent/list',
        'params': {},
      });
    } catch (e) {
      debugPrint('[ACP] connect() error: $e');
      state = state.copyWith(
        state: AcpConnectionState.failed('$e'),
        error: '$e',
      );
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data, int pairId, Completer<void> pairCompleter) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final method = json['method'] as String?;
      final msgId = json['id'];
      final hasResult = json.containsKey('result');
      final hasError = json.containsKey('error');
      final errorMsg = json['error'];
      debugPrint('[ACP] ← msg: method=$method id=$msgId hasResult=$hasResult hasError=$hasError error=$errorMsg');

      // Handle auth/pair response
      if (json['id'] == pairId && !pairCompleter.isCompleted) {
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['paired'] == true) {
          final daemonId = result['daemonId'] as String?;
          debugPrint('[ACP] auth/pair succeeded, daemonId=$daemonId');
          state = state.copyWith(daemonId: daemonId);
          pairCompleter.complete();
          return;
        }
        final error = json['error'] as Map<String, dynamic>?;
        final msg = error?['message'] as String? ?? 'Pairing rejected';
        debugPrint('[ACP] auth/pair failed: $msg');
        pairCompleter.completeError(Exception(msg));
        return;
      }

      // Handle daemon/identified (relay sends this when daemon is online)
      if (method == 'daemon/identified') {
        final params = json['params'] as Map<String, dynamic>?;
        final di = params?['daemonId'] as String?;
        debugPrint('[ACP] daemon/identified: daemonId=$di');
        if (di != null) {
          state = state.copyWith(daemonId: di);
        }
        return;
      }

      // Handle daemon/disconnected
      if (method == 'daemon/disconnected') {
        debugPrint('[ACP] daemon/disconnected');
        state = state.copyWith(
          daemonId: null,
          agents: const [],
          clearSelectedAgent: true,
          clearAgentInfo: true,
          clearCapabilities: true,
        );
        return;
      }

      if (method == 'agent/list') {
        final params = json['params'] as Map<String, dynamic>?;
        if (params != null) {
          debugPrint('[ACP] agent/list notification with ${(params['agents'] as List?)?.length} agents');
          _handleAgentList(params);
          return;
        }
      }

      final result = json['result'] as Map<String, dynamic>?;
      if (result != null && result['agents'] is List<dynamic>) {
        final agentsList = result['agents'] as List<dynamic>;
        debugPrint('[ACP] agent/list response with ${agentsList.length} agents');
        for (final a in agentsList) {
          debugPrint('[ACP]   agent: id=${(a as Map)['id']} name=${a['name']} online=${a['online']}');
        }
        _handleAgentList(result);
        return;
      }

      // Handle initialize response (forwarded from opencode via daemon)
      if (_initId != null && json['id'] == _initId) {
        debugPrint('[ACP] initialize response received');
        if (result != null) {
          _handleInitialize(result);
          _initId = null;
          return;
        }
      }

      // Route other messages to chat/session providers
      debugPrint('[ACP] routing message to _messageController');
      _messageController.add(json);
    } catch (e) {
      debugPrint('[ACP] _handleMessage error: $e');
    }
  }

  void _handleAgentList(Map<String, dynamic> data) {
    final agents =
        (data['agents'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(AcpAgent.fromJson)
            .toList() ??
        [];
    final selectedId = state.selectedAgentId;
    final selectedStillExists = agents.any((a) => a.id == selectedId);
    final nextSelectedId = selectedStillExists
        ? selectedId
        : _firstAgentWhereOrNull(agents, (agent) => agent.online)?.id;
    final selectedAgent = _firstAgentWhereOrNull(
      agents,
      (agent) => agent.id == nextSelectedId,
    );

    state = state.copyWith(
      agents: agents,
      selectedAgentId: nextSelectedId,
      agentInfo: selectedAgent?.toAgentInfo(),
      clearAgentInfo: selectedAgent == null,
    );
  }

  void _handleInitialize(Map<String, dynamic> result) {
    final agentInfoData = result['agentInfo'] as Map<String, dynamic>?;
    final capabilitiesData =
        result['agentCapabilities'] as Map<String, dynamic>?;

    AgentInfo? agentInfo;
    AgentCapabilities? capabilities;

    if (agentInfoData != null) {
      agentInfo = AgentInfo.fromJson(agentInfoData);
    }
    if (capabilitiesData != null) {
      capabilities = AgentCapabilities.fromJson(capabilitiesData);
    }

    state = state.copyWith(agentInfo: agentInfo, capabilities: capabilities);
  }

  Future<void> sendRaw(Map<String, dynamic> message) async {
    final channel = state.channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      _onDisconnected('Send error: $e');
    }
  }

  Future<void> sendSessionMessage(String sessionId, String text) async {
    await sendRaw({
      'jsonrpc': '2.0',
      'id': _nextId,
      'method': 'session/prompt',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
        'prompt': [
          {'type': 'text', 'text': text},
        ],
      },
    });
  }

  Future<void> loadSession(String sessionId, String cwd) async {
    debugPrint('[ACP] sending session/load id=$sessionId cwd=$cwd');
    await sendRaw({
      'jsonrpc': '2.0',
      'id': _nextId,
      'method': 'session/load',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
        'cwd': cwd,
        'mcpServers': <Map<String, dynamic>>[],
      },
    });
  }

  Future<void> loadAgents() async {
    await sendRaw({
      'jsonrpc': '2.0',
      'id': _nextId,
      'method': 'agent/list',
      'params': {},
    });
  }

  void selectAgent(String agentId) {
    final selectedAgent = _firstAgentWhereOrNull(
      state.agents,
      (agent) => agent.id == agentId,
    );
    if (selectedAgent == null) return;
    state = state.copyWith(
      selectedAgentId: agentId,
      agentInfo: selectedAgent.toAgentInfo(),
      clearCapabilities: true,
    );
  }

  void _onDisconnected(String reason) {
    _sub?.cancel();
    _sub = null;
    _initId = null;
    state = state.copyWith(
      clearChannel: true,
      state: const AcpConnectionState.disconnected(),
      paired: false,
      error: reason,
    );
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (state.pairingCode == null) return;
    _reconnectTimer?.cancel();
    final delay = Duration(
      seconds: min(pow(2, _reconnectAttempts).toInt(), 30),
    );
    _reconnectAttempts++;
    state = state.copyWith(state: const AcpConnectionState.reconnecting());
    _reconnectTimer = Timer(delay, () {
      final code = state.pairingCode;
      final url = state.relayUrl;
      if (code != null) connect(code, relayUrl: url);
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    _initId = null;
    state.channel?.sink.close();
    state = const AcpConnection();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectTimer?.cancel();
    _initId = null;
    _messageController.close();
    state.channel?.sink.close();
    super.dispose();
  }
}

AcpAgent? _firstAgentWhereOrNull(
  Iterable<AcpAgent> agents,
  bool Function(AcpAgent agent) test,
) {
  for (final agent in agents) {
    if (test(agent)) return agent;
  }
  return null;
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, AcpConnection>((ref) {
      return ConnectionNotifier(ref);
    });
