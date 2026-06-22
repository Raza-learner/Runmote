import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_state.dart';
import '../services/acp_client.dart';
import 'preferences_provider.dart';
import 'active_session_provider.dart';
import '../../features/chat/chat_provider.dart';

class ConnectionNotifier extends StateNotifier<AcpConnectionState> {
  ACPClient? _client;
  StreamSubscription<AcpConnectionState>? _stateSub;
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<String>? _errorSub;

  final Ref ref;

  ConnectionNotifier(this.ref) : super(const AcpConnectionState.disconnected()) {
    _initClient();
  }

  ACPClient get client {
    if (_client == null) {
      throw StateError('Client not initialized');
    }
    return _client!;
  }

  Future<void> _initClient() async {
    try {
      final service = await ref.read(preferencesServiceProvider.future);
      final c = ACPClient(service.relayUrl);
      _client = c;
      _stateSub = c.connectionState.listen((s) {
        if (mounted) state = s;
      });
      _messageSub = c.messages.listen(_handleMessage);
      _errorSub = c.errors.listen((_) {});
      c.connect();
    } catch (_) {}
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final method = msg['method'] as String?;
    if (method == null) return;

    if (method == 'session/response') {
      final params = msg['params'] as Map<String, dynamic>?;
      if (params == null) return;
      final sessionId = params['sessionId'] as String?;
      if (sessionId == null) return;
      final activeSessionId = ref.read(activeSessionProvider);
      if (activeSessionId == sessionId) {
        ref.read(chatProvider(sessionId).notifier).handleRelayMessage(params);
      }
    }
  }

  void sendRelaySessionMessage(String sessionId, String text) {
    final request = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'session/message',
      'params': {
        'sessionId': sessionId,
        'message': text,
      },
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
    });
    send(request);
  }

  void sendPermissionResponse({
    required String sessionId,
    required String permissionRequestId,
    required bool approved,
  }) {
    final request = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'session/permission',
      'params': {
        'sessionId': sessionId,
        'permissionRequestId': permissionRequestId,
        'approved': approved,
      },
      'id': 'perm_${DateTime.now().millisecondsSinceEpoch}',
    });
    send(request);
  }

  void sendFileUpload({
    required String sessionId,
    required String fileName,
    required String fileData, // base64-encoded
    required String mimeType,
  }) {
    final request = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'session/fileUpload',
      'params': {
        'sessionId': sessionId,
        'fileName': fileName,
        'fileData': fileData,
        'mimeType': mimeType,
      },
      'id': 'file_${DateTime.now().millisecondsSinceEpoch}',
    });
    send(request);
  }

  void reconnect() {
    _client?.disconnect();
    _client?.connect();
  }

  void updateRelayUrl(String url) {
    _client?.updateRelayUrl(url);
  }

  Stream<Map<String, dynamic>> get messages {
    final c = _client;
    if (c != null) return c.messages;
    throw StateError('Client not initialized');
  }

  void send(String data) {
    _client?.send(data);
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _messageSub?.cancel();
    _errorSub?.cancel();
    _client?.dispose();
    super.dispose();
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, AcpConnectionState>(
  (ref) => ConnectionNotifier(ref),
);
