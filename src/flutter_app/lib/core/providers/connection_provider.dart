import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/connection_state.dart';
import '../models/agent_info.dart';
import '../models/agent_capabilities.dart';
import 'database_provider.dart';

class AcpConnection {
  final WebSocketChannel? channel;
  final AcpConnectionState state;
  final String? pairingCode;
  final String? relayUrl;
  final String? daemonId;
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
    this.agentInfo,
    this.capabilities,
    this.paired = false,
    this.error,
  });

  AcpConnection copyWith({
    WebSocketChannel? channel,
    AcpConnectionState? state,
    String? pairingCode,
    String? relayUrl,
    String? daemonId,
    AgentInfo? agentInfo,
    AgentCapabilities? capabilities,
    bool? paired,
    String? error,
    bool clearChannel = false,
    bool clearAgentInfo = false,
    bool clearCapabilities = false,
  }) {
    return AcpConnection(
      channel: clearChannel ? null : channel ?? this.channel,
      state: state ?? this.state,
      pairingCode: pairingCode ?? this.pairingCode,
      relayUrl: relayUrl ?? this.relayUrl,
      daemonId: daemonId ?? this.daemonId,
      agentInfo: clearAgentInfo ? null : agentInfo ?? this.agentInfo,
      capabilities:
          clearCapabilities ? null : capabilities ?? this.capabilities,
      paired: paired ?? this.paired,
      error: error ?? this.error,
    );
  }
}

class ConnectionNotifier extends StateNotifier<AcpConnection> {
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final Ref _ref;

  final _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  int _msgId = 0;

  ConnectionNotifier(this._ref) : super(const AcpConnection());

  int get _nextId => ++_msgId;

  Future<void> connect(String code, {String? relayUrl}) async {
    if (state.state case AcpConnectionState() when
        state.state is Connected || state.state is Connecting) {
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

      // Send initialize to get agent info
      sendRaw({
        'jsonrpc': '2.0',
        'id': _nextId,
        'method': 'initialize',
        'params': {'protocolVersion': 1},
      });
    } catch (e) {
      state = state.copyWith(
        state: AcpConnectionState.failed('$e'),
        error: '$e',
      );
      _scheduleReconnect();
    }
  }

  void _handleMessage(
      dynamic data, int pairId, Completer<void> pairCompleter) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final method = json['method'] as String?;

      // Handle auth/pair response
      if (json['id'] == pairId && !pairCompleter.isCompleted) {
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['paired'] == true) {
          final daemonId = result['daemonId'] as String?;
          state = state.copyWith(daemonId: daemonId);
          pairCompleter.complete();
          return;
        }
        final error = json['error'] as Map<String, dynamic>?;
        final msg = error?['message'] as String? ?? 'Pairing rejected';
        pairCompleter.completeError(Exception(msg));
        return;
      }

      // Handle daemon/identified (relay sends this when daemon is online)
      if (method == 'daemon/identified') {
        final params = json['params'] as Map<String, dynamic>?;
        final di = params?['daemonId'] as String?;
        if (di != null) {
          state = state.copyWith(daemonId: di);
        }
        return;
      }

      // Handle daemon/disconnected
      if (method == 'daemon/disconnected') {
        state = state.copyWith(
          daemonId: null,
          clearAgentInfo: true,
          clearCapabilities: true,
        );
        return;
      }

      // Handle initialize response (forwarded from opencode via daemon)
      final result = json['result'];
      if (method == 'initialize' && result != null) {
        _handleInitialize(result as Map<String, dynamic>);
        return;
      }

      // Route other messages to chat/session providers
      _messageController.add(json);
    } catch (_) {}
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

    state = state.copyWith(
      agentInfo: agentInfo,
      capabilities: capabilities,
    );
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
        'sessionId': sessionId,
        'content': [
          {'type': 'text', 'text': text},
        ],
      },
    });
  }

  void _onDisconnected(String reason) {
    _sub?.cancel();
    _sub = null;
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
    state.channel?.sink.close();
    state = const AcpConnection();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reconnectTimer?.cancel();
    _messageController.close();
    state.channel?.sink.close();
    super.dispose();
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, AcpConnection>((ref) {
  return ConnectionNotifier(ref);
});
