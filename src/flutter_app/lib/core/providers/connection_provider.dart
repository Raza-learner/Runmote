import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/agent_capabilities.dart';
import '../models/agent_info.dart';
import '../models/connection_state.dart';
import 'database_provider.dart';
import 'session_list_provider.dart';

const _defaultRelayUrl = 'wss://runmote-relay.onrender.com';

String _sanitizeRelayUrl(String url) {
  var u = url.trim();
  while (u.endsWith('/')) u = u.substring(0, u.length - 1);
  if (u.startsWith('https://')) u = 'wss://${u.substring(8)}';
  if (u.startsWith('http://')) u = 'ws://${u.substring(7)}';
  return u;
}

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
  final String? token;
  final String? relayUrl;
  final String? daemonId;
  final String? daemonName;
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
    this.token,
    this.relayUrl,
    this.daemonId,
    this.daemonName,
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
    String? token,
    String? relayUrl,
    String? daemonId,
    String? daemonName,
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
      token: token ?? this.token,
      relayUrl: relayUrl ?? this.relayUrl,
      daemonId: daemonId ?? this.daemonId,
      daemonName: daemonName ?? this.daemonName,
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

  /// Set to true when a `daemon/disconnected` message is received, so that
  /// the subsequent WebSocket `onDone`/`onError` (Path B) skips duplicate
  /// work and avoids scheduling a reconnect — the daemon is offline, not the
  /// relay connection.
  bool _daemonDisconnected = false;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  int _msgId = 0;

  // Per-agent capabilities/info, keyed by agent ID.
  // Preserved across agent switches so selecting an agent uses its own data.
  final _agentCapabilities = <String, AgentCapabilities>{};
  final _agentInfos = <String, AgentInfo>{};

  ConnectionNotifier(this._ref) : super(const AcpConnection());

  int get _nextId => ++_msgId;

  // ── Heartbeat (ping/pong) ────────────────────────────────────────
  Timer? _pingTimer;
  bool _pongReceived = true;

  static const _pingInterval = Duration(seconds: 25);

  void _startPing() {
    _stopPing();
    _pongReceived = true;
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (!_pongReceived) {
        debugPrint('[RUNMOTE] ping timeout — no pong for $_pingInterval');
        _onDisconnected('Ping timeout');
        return;
      }
      _pongReceived = false;
      sendRaw({
        'jsonrpc': '2.0',
        'method': r'$/ping',
      });
      // If no pong within the next interval, the next tick triggers timeout
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _handlePong() {
    _pongReceived = true;
  }

  Future<void> connect(String code, {String? relayUrl}) async {
    if (state.state case AcpConnectionState()
        when state.state is Connected || state.state is Connecting) {
      return;
    }

    final url = _sanitizeRelayUrl(relayUrl ?? state.relayUrl ?? _defaultRelayUrl);
    debugPrint('[RUNMOTE] connect: url=$url');

    state = state.copyWith(
      state: const AcpConnectionState.connecting(),
      pairingCode: code,
      relayUrl: url,
      paired: false,
      error: null,
    );

    try {
      final uri = Uri.parse('$url/app');
      debugPrint('[RUNMOTE] connect: ws uri=$uri');
      final channel = WebSocketChannel.connect(uri);

      await channel.ready;

      state = state.copyWith(channel: channel);
      _reconnectAttempts = 0;
      _daemonDisconnected = false;

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
      _startPing();

      // Save pairing code
      final p = await _ref.read(preferencesServiceProvider.future);
      await p.setPairingCode(code);

      // Save token for reconnection
      if (state.token != null) {
        await p.setAuthToken(state.token!);
        await p.setRelayUrl(url);
      }

      sendRaw({
        'jsonrpc': '2.0',
        'id': _nextId,
        'method': 'agent/list',
        'params': {},
      });
    } catch (e) {
      debugPrint('[RUNMOTE] connect error: $e');
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

  Future<bool> connectWithToken(String token, String relayUrl) async {
    if (state.state case AcpConnectionState()
        when state.state is Connected || state.state is Connecting) {
      return true;
    }

    final url = _sanitizeRelayUrl(relayUrl);
    debugPrint('[RUNMOTE] connectWithToken: url=$url');
    state = state.copyWith(
      state: const AcpConnectionState.connecting(),
      relayUrl: url,
      error: null,
    );

    try {
      final uri = Uri.parse('$url/app');
      debugPrint('[RUNMOTE] connectWithToken: ws uri=$uri');
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;

      state = state.copyWith(channel: channel, token: token);
      _reconnectAttempts = 0;
      _daemonDisconnected = false;

      final authCompleter = Completer<bool>();
      final authId = _nextId;
      sendRaw({
        'jsonrpc': '2.0',
        'id': authId,
        'method': 'auth/token',
        'params': {'token': token},
      });

      _sub = channel.stream.listen(
        (data) => _handleTokenAuth(data, authId, authCompleter),
        onError: (e) => _onDisconnected('Connection error: $e'),
        onDone: () => _onDisconnected('Connection closed'),
        cancelOnError: false,
      );

      final ok = await authCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );

      if (ok) {
        state = state.copyWith(
          state: const AcpConnectionState.connected(),
          paired: true,
        );
        _startPing();
        final p = await _ref.read(preferencesServiceProvider.future);
        if (state.token != null) {
          await p.setAuthToken(state.token!);
          await p.setRelayUrl(url);
        }
        sendRaw({
          'jsonrpc': '2.0',
          'id': _nextId,
          'method': 'agent/list',
          'params': {},
        });
        return true;
      } else {
        _sub?.cancel();
        _sub = null;
        channel.sink.close();
        state = state.copyWith(
          state: const AcpConnectionState.disconnected(),
          clearChannel: true,
        );
        return false;
      }
    } catch (e) {
      debugPrint('[RUNMOTE] connectWithToken error: $e');
      _sub?.cancel();
      _sub = null;
      state = state.copyWith(
        state: AcpConnectionState.failed('$e'),
        error: '$e',
        clearChannel: true,
      );
      return false;
    }
  }

  void _handleTokenAuth(
      dynamic data, int authId, Completer<bool> completer) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final method = json['method'] as String?;

      if (method == r'$/pong') {
        _handlePong();
        return;
      }

      // Handle auth/token response
      if (json['id'] == authId && !completer.isCompleted) {
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['authenticated'] == true) {
          final daemonId = result['daemonId'] as String?;
          final daemonName = result['daemonName'] as String?;
          final daemonConnected = result['daemonConnected'] as bool? ?? daemonId != null;
          debugPrint('[RUNMOTE] auth/token success: daemonId=$daemonId, name=$daemonName, daemonConnected=$daemonConnected');
          state = state.copyWith(
            daemonId: daemonId,
            daemonName: daemonName,
            daemonConnected: daemonConnected,
          );
          completer.complete(true);
          return;
        }
        debugPrint('[RUNMOTE] auth/token rejected');
        completer.complete(false);
        return;
      }

      // After auth, handle regular messages the same way as _handleMessage
      if (method == 'daemon/identified') {
        final params = json['params'] as Map<String, dynamic>?;
        final di = params?['daemonId'] as String?;
        final dn = params?['name'] as String?;
        if (di != null) {
          state = state.copyWith(
            daemonId: di,
            daemonName: dn,
            daemonConnected: true,
          );
        } else {
          state = state.copyWith(daemonConnected: true);
        }
        return;
      }

      if (method == 'daemon/disconnected') {
        debugPrint('[RUNMOTE] daemon/disconnected');
        _daemonDisconnected = true;
        _reconnectTimer?.cancel();
        _agentCapabilities.clear();
        _agentInfos.clear();
        _ref.read(activeSessionsProvider.notifier).clear();
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

      if (result != null && result['agentCapabilities'] is Map<String, dynamic>) {
        _handleInitialize(result);
        return;
      }

      // Route other messages to chat/session providers
      _messageController.add(json);
    } catch (e) {
      debugPrint('[RUNMOTE] _handleTokenAuth error: $e');
    }
  }

  void _handleMessage(dynamic data, int pairId, Completer<void> pairCompleter) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final method = json['method'] as String?;

      // Handle pong
      if (method == r'$/pong') {
        _handlePong();
        return;
      }

      // Handle auth/pair response
      if (json['id'] == pairId && !pairCompleter.isCompleted) {
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['paired'] == true) {
          final daemonId = result['daemonId'] as String?;
          final daemonName = result['daemonName'] as String?;
          final token = result['token'] as String?;
          state = state.copyWith(
            daemonId: daemonId,
            daemonName: daemonName,
            token: token,
            daemonConnected: daemonId != null,
          );
          pairCompleter.complete();
          return;
        }
        final error = json['error'] as Map<String, dynamic>?;
        final msg = error?['message'] as String? ?? 'Pairing rejected';
        debugPrint('[RUNMOTE] auth/pair failed: $msg');
        pairCompleter.completeError(Exception(msg));
        return;
      }

      // Handle daemon/identified (relay sends this when daemon is online)
      if (method == 'daemon/identified') {
        final params = json['params'] as Map<String, dynamic>?;
        final di = params?['daemonId'] as String?;
        final dn = params?['name'] as String?;
        if (di != null) {
          state = state.copyWith(
            daemonId: di,
            daemonName: dn,
            daemonConnected: true,
          );
        } else {
          state = state.copyWith(daemonConnected: true);
        }
        return;
      }

      // Handle daemon/disconnected
      if (method == 'daemon/disconnected') {
        debugPrint('[RUNMOTE] daemon/disconnected');
        _daemonDisconnected = true;
        _reconnectTimer?.cancel();
        _agentCapabilities.clear();
        _agentInfos.clear();
        _ref.read(activeSessionsProvider.notifier).clear();
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
      debugPrint('[RUNMOTE] _handleMessage error: $e');
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
    _stopPing();
    _sub?.cancel();
    _sub = null;
    // If Path A (daemon/disconnected message) already handled cleanup,
    // skip the expensive re-clear and don't schedule reconnect — the
    // daemon is offline, not the relay connection.
    if (_daemonDisconnected) {
      _daemonDisconnected = false;
      state = state.copyWith(
        clearChannel: true,
        state: const AcpConnectionState.disconnected(),
        error: reason,
      );
      return;
    }
    _agentCapabilities.clear();
    _agentInfos.clear();
    _ref.read(activeSessionsProvider.notifier).clear();
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
    final token = state.token;
    final relayUrl = state.relayUrl;
    if (token == null || relayUrl == null) return;

    _reconnectTimer?.cancel();
    final delay = Duration(
      seconds: min(pow(2, _reconnectAttempts).toInt(), 60),
    );
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, () async {
      state = state.copyWith(state: const AcpConnectionState.reconnecting());
      final ok = await connectWithToken(token, relayUrl);
      if (!ok) {
        // Retry on failure — keep backing off
        _scheduleReconnect();
      }
    });
  }

  Future<void> disconnect() async {
    _stopPing();
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
    _stopPing();
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
