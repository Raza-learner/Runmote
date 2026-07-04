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
import 'preferences_provider.dart';

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
  final bool daemonConnected;

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
    this.daemonConnected = false,
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
    bool? daemonConnected,
    bool clearChannel = false,
    bool clearSelectedAgent = false,
    bool clearAgentInfo = false,
    bool clearCapabilities = false,
    bool clearDaemonConnected = false,
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
      daemonConnected:
          clearDaemonConnected ? false : daemonConnected ?? this.daemonConnected,
    );
  }
}

class ConnectionNotifier extends StateNotifier<AcpConnection> {
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final Ref _ref;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  int _msgId = 0;

  // Per-agent capabilities/info, keyed by agent ID.
  // Preserved across agent switches so selecting an agent uses its own data.
  final _agentCapabilities = <String, AgentCapabilities>{};
  final _agentInfos = <String, AgentInfo>{};

  ConnectionNotifier(this._ref) : super(const AcpConnection());

  int get _nextId => ++_msgId;

  Future<void> connect(String code, {String? relayUrl}) async {
    if (state.state case AcpConnectionState()
        when state.state is Connected || state.state is Connecting) {
      return;
    }

    final url = relayUrl ?? state.relayUrl ?? 'ws://localhost:8000';

    state = state.copyWith(
      state: const AcpConnectionState.connecting(),
      pairingCode: code,
      relayUrl: url,
      paired: false,
      error: null,
    );

    try {
      final uri = Uri.parse('$url/app');
      final channel = WebSocketChannel.connect(uri);

      await channel.ready;

      state = state.copyWith(channel: channel);
      _reconnectAttempts = 0;

      // Send auth/pair with the pairing code
      final pairCompleter = Completer<void>();
      final pairId = _nextId;
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
      await pairCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Pairing timed out'),
      );

      state = state.copyWith(
        state: const AcpConnectionState.connected(),
        paired: true,
      );

      // Save pairing code
      final p = await _ref.read(preferencesServiceProvider.future);
      await p.setPairingCode(code);

      sendRaw({
        'jsonrpc': '2.0',
        'id': _nextId,
        'method': 'agent/list',
        'params': {},
      });
    } catch (e) {
      debugPrint('[ACP] connect error: $e');
      final msg = '$e';
      // Don't auto-reconnect on auth errors — the pairing code is stale.
      final isAuthError = msg.contains('Pairing') || msg.contains('code');
      state = state.copyWith(
        state: AcpConnectionState.failed('$e'),
        error: '$e',
        paired: isAuthError ? false : state.paired,
      );
      if (!isAuthError) _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data, int pairId, Completer<void> pairCompleter) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final method = json['method'] as String?;

      // Handle auth/pair response
      if (json['id'] == pairId && !pairCompleter.isCompleted) {
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['paired'] == true) {
          final daemonId = result['daemonId'] as String?;
          state = state.copyWith(
            daemonId: daemonId,
            daemonConnected: daemonId != null,
          );
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
        if (di != null) {
          state = state.copyWith(daemonId: di, daemonConnected: true);
        } else {
          state = state.copyWith(daemonConnected: true);
        }
        return;
      }

      // Handle daemon/disconnected
      if (method == 'daemon/disconnected') {
        debugPrint('[ACP] daemon/disconnected');
        _agentCapabilities.clear();
        _agentInfos.clear();
        state = state.copyWith(
          daemonId: null,
          agents: const [],
          clearSelectedAgent: true,
          clearAgentInfo: true,
          clearCapabilities: true,
          daemonConnected: false,
        );
        return;
      }

      if (method == 'agent/list') {
        final params = json['params'] as Map<String, dynamic>?;
        if (params != null) {
          _handleAgentList(params);
          return;
        }
      }

      final result = json['result'] as Map<String, dynamic>?;
      if (result != null && result['agents'] is List<dynamic>) {
        _handleAgentList(result);
        return;
      }

      // Handle initialize response (forwarded from agent via daemon)
      // Daemon sends agent/initialize for each agent; result contains agentCapabilities
      if (result != null && result['agentCapabilities'] is Map<String, dynamic>) {
        _handleInitialize(result);
        return;
      }

      // Route other messages to chat/session providers
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
    final agentId = selectedStillExists
        ? selectedId
        : _firstAgentWhereOrNull(agents, (agent) => agent.online)?.id;
    state = state.copyWith(
      agents: agents,
      selectedAgentId: agentId,
      agentInfo: agentId != null
          ? (_agentInfos[agentId] ??
              _firstAgentWhereOrNull(agents, (a) => a.id == agentId)?.toAgentInfo())
          : null,
      capabilities: agentId != null ? _agentCapabilities[agentId] : null,
    );
  }

  void _handleInitialize(Map<String, dynamic> result) {
    final agentId = result['agentId'] as String?;
    if (agentId == null) return;

    final agentInfoData = result['agentInfo'] as Map<String, dynamic>?;
    final capabilitiesData =
        result['agentCapabilities'] as Map<String, dynamic>?;

    if (agentInfoData != null) {
      _agentInfos[agentId] = AgentInfo.fromJson(agentInfoData);
    }
    if (capabilitiesData != null) {
      _agentCapabilities[agentId] =
          AgentCapabilities.fromJson(capabilitiesData);
    }

    // Only update the connection state if this response is for the selected agent.
    if (agentId == state.selectedAgentId) {
      state = state.copyWith(
        agentInfo: _agentInfos[agentId],
        capabilities: _agentCapabilities[agentId],
      );
    }
  }

  void sendRaw(Map<String, dynamic> message) {
    final channel = state.channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      _onDisconnected('Send error: $e');
    }
  }

  int sendSessionMessage(String sessionId, String text,
      {List<Map<String, dynamic>>? extra}) {
    final id = _nextId;
    final prompt = <Map<String, dynamic>>[
      {'type': 'text', 'text': text},
    ];
    if (extra != null) prompt.addAll(extra);
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'session/prompt',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
        'prompt': prompt,
      },
    });
    return id;
  }

  Future<int> loadSession(String sessionId, String cwd) async {
    final id = _nextId;
    final prefs = await _ref.read(preferencesServiceProvider.future);
    final mcps = prefs.getMcpServers().map((s) => s.toJson()).toList();
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'session/load',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
        'cwd': cwd,
        'mcpServers': mcps,
      },
    });
    return id;
  }

  void closeSession(String sessionId) {
    sendRaw({
      'jsonrpc': '2.0',
      'id': _nextId,
      'method': 'session/close',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
      },
    });
  }

  Future<int> resumeSession(String sessionId, String cwd) async {
    final id = _nextId;
    final prefs = await _ref.read(preferencesServiceProvider.future);
    final mcps = prefs.getMcpServers().map((s) => s.toJson()).toList();
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'session/resume',
      'params': {
        if (state.selectedAgentId != null) 'agentId': state.selectedAgentId,
        'sessionId': sessionId,
        'cwd': cwd,
        'mcpServers': mcps,
      },
    });
    return id;
  }

  void loadAgents() {
    sendRaw({
      'jsonrpc': '2.0',
      'id': _nextId,
      'method': 'agent/list',
      'params': {},
    });
  }

  int getHome() {
    final id = _nextId;
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'filesystem/get_home',
      'params': {},
    });
    return id;
  }

  int listDirectory(String path, {bool showHidden = false}) {
    final id = _nextId;
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'filesystem/list_directory',
      'params': {'path': path, 'showHidden': showHidden},
    });
    return id;
  }

  int listDrives() {
    final id = _nextId;
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'filesystem/list_drives',
      'params': {},
    });
    return id;
  }

  int readTextFile(String path, {int? line, int? limit}) {
    final id = _nextId;
    final params = <String, dynamic>{'path': path};
    if (line != null) params['line'] = line;
    if (limit != null) params['limit'] = limit;
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'fs/read_text_file',
      'params': params,
    });
    return id;
  }

  int writeTextFile(String path, String content) {
    final id = _nextId;
    sendRaw({
      'jsonrpc': '2.0',
      'id': id,
      'method': 'fs/write_text_file',
      'params': {'path': path, 'content': content},
    });
    return id;
  }

  void selectAgent(String agentId) {
    final selectedAgent = _firstAgentWhereOrNull(
      state.agents,
      (agent) => agent.id == agentId,
    );
    if (selectedAgent == null) return;
    state = state.copyWith(
      selectedAgentId: agentId,
      agentInfo: _agentInfos[agentId] ?? selectedAgent.toAgentInfo(),
      capabilities: _agentCapabilities[agentId],
    );
  }

  void _onDisconnected(String reason) {
    _sub?.cancel();
    _sub = null;
    _agentCapabilities.clear();
    _agentInfos.clear();
    state = state.copyWith(
      clearChannel: true,
      state: const AcpConnectionState.disconnected(),
      paired: false,
      error: reason,
      daemonConnected: false,
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
    _agentCapabilities.clear();
    _agentInfos.clear();
    state.channel?.sink.close();
    state = const AcpConnection();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectTimer?.cancel();
    _messageController.close();
    state.channel?.sink.close();
    _agentCapabilities.clear();
    _agentInfos.clear();
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
