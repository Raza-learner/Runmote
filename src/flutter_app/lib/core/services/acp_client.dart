import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/connection_state.dart';

class ACPClient {
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<AcpConnectionState> _stateController =
      StreamController<AcpConnectionState>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempt = 0;
  String _relayUrl;
  bool _disposed = false;
  bool _connecting = false;
  static const int _maxReconnectDelay = 30;
  static const int _pingIntervalSec = 25;

  ACPClient(this._relayUrl);

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<AcpConnectionState> get connectionState => _stateController.stream;
  Stream<String> get errors => _errorController.stream;
  String get relayUrl => _relayUrl;

  bool get isConnected =>
      _channel != null && _channel!.ready == Future<void>.value();

  void connect() {
    if (_disposed || _connecting) return;
    _connecting = true;
    _stateController.add(const AcpConnectionState.connecting());
    _initConnection();
  }

  Future<void> _initConnection() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_relayUrl));
      await _channel!.ready;
      if (_disposed) return;
      _stateController.add(const AcpConnectionState.connected());
      _reconnectAttempt = 0;
      _startPing();
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      if (!_disposed) _onError(e);
    } finally {
      _connecting = false;
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: _pingIntervalSec),
      (_) => send(jsonEncode({'jsonrpc': '2.0', 'method': '\$/ping'})),
    );
  }

  void updateRelayUrl(String newUrl) {
    _relayUrl = newUrl;
    disconnect();
    connect();
  }

  void send(String data) {
    _channel?.sink.add(data);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pingTimer?.cancel();
    _cleanup();
    _stateController.add(const AcpConnectionState.disconnected());
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _messageController.close();
    _stateController.close();
    _errorController.close();
  }

  void _onMessage(dynamic data) {
    try {
      final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
      if (msg['method'] == '\$/pong') return;
      _messageController.add(msg);
    } catch (_) {}
  }

  void _onError(dynamic error) {
    _errorController.add('$error');
    _cleanup();
    _scheduleReconnect();
  }

  void _onDone() {
    _cleanup();
    _scheduleReconnect();
  }

  void _cleanup() {
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _stateController.add(const AcpConnectionState.reconnecting());
    final delay = Duration(
      seconds: _reconnectAttempt < 5
          ? (1 << _reconnectAttempt)
          : _maxReconnectDelay,
    );
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, connect);
  }
}
