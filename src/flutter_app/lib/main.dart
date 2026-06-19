import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String relayUrl = 'ws://192.168.1.12:8000/app';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ACP Remote',
      home: MyHomePage(title: 'ACP Remote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  late final WebSocketChannel _channel;
  int _msgId = 1;
  String? _sessionId;
  String? _pendingText;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(relayUrl));
    _channel.stream.listen(_onMessage, onError: (e) {
      _addMessage('system', 'Error: $e');
    });
    _sendInitialize();
  }

  void _addMessage(String from, String text) {
    setState(() => _messages.add({'from': from, 'text': text}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendJson(String jsonMsg) {
    _channel.sink.add(jsonMsg);
  }

  void _sendInitialize() {
    _sendJson(jsonEncode({
      'jsonrpc': '2.0',
      'id': _msgId++,
      'method': 'initialize',
      'params': {'protocolVersion': 1},
    }));
  }

  void _sendSessionNew() {
    _sendJson(jsonEncode({
      'jsonrpc': '2.0',
      'id': _msgId++,
      'method': 'session/new',
      'params': {'cwd': '/home/raza/Projects/ACP', 'mcpServers': []},
    }));
  }

  void _sendPrompt(String text) {
    _addMessage('you', text);
    if (_sessionId == null) {
      _pendingText = text;
      _sendSessionNew();
      return;
    }
    final jsonMsg = jsonEncode({
      'jsonrpc': '2.0',
      'id': _msgId++,
      'method': 'session/prompt',
      'params': {
        'sessionId': _sessionId,
        'prompt': [{'type': 'text', 'text': text}],
      },
    });
    _sendJson(jsonMsg);
  }

  void _appendToLast(String text) {
    setState(() {
      if (_messages.isNotEmpty && _messages.last['from'] == 'agent') {
        _messages.last['text'] = _messages.last['text']! + text;
      } else {
        _messages.add({'from': 'agent', 'text': text});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onMessage(dynamic data) {
    final text = data.toString();
    try {
      final msg = jsonDecode(text);
      if (msg is Map) {
        if (msg['method'] == 'session/update') {
          final params = msg['params'] as Map? ?? {};
          final update = (params['update'] as Map?) ?? {};
          final sup = update['sessionUpdate'] as String?;
          // ignore internal thoughts and usage updates
          if (sup == 'agent_thought_chunk' || sup == 'usage_update') {
            return;
          }
          // new format: params.part or params.update.part
          final part = params['part'] ?? update['part'];
          if (part is Map && part['type'] == 'text') {
            _appendToLast(part['text']);
            return;
          }
          // old format: update.sessionUpdate = agent_message_chunk
          if (sup == 'agent_message_chunk') {
            final content = update['content'];
            if (content is Map && content['type'] == 'text') {
              _appendToLast(content['text']);
              return;
            }
          }
          // show tool calls and permission requests
          if (sup != null && sup != 'available_commands_update') {
            _addMessage('system', sup);
          }
          return;
        }
        if (msg['id'] != null) {
          if (msg['error'] != null) {
            final errMsg = msg['error']['message'] ?? '';
            final errSid = msg['error']?['data']?['sessionId'] as String?;
            if (errSid != null && errSid == _sessionId) {
              _sessionId = null;
              _addMessage('system', 'Session expired, creating new one...');
              _sendSessionNew();
              return;
            }
            _addMessage('agent', 'Error: $errMsg');
            return;
          }
          final result = msg['result'];
          if (result is Map) {
            if (result['sessionId'] is String && _sessionId == null) {
              _sessionId = result['sessionId'];
              _addMessage('system', 'Session created: ${_sessionId!.substring(0, 20)}...');
              if (_pendingText != null) {
                final t = _pendingText!;
                _pendingText = null;
                _sendPrompt(t);
              }
              return;
            }
            if (result['agentInfo'] != null) {
              _addMessage('system', 'Connected: ${result['agentInfo']['name']} ${result['agentInfo']['version']}');
              _sendSessionNew();
              return;
            }
          }
          return;  // suppress raw JSON-RPC wrappers
        }
      }
    } catch (_) {}
    _addMessage('agent', text);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendPrompt(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isYou = msg['from'] == 'you';
                final isSystem = msg['from'] == 'system';
                final bgColor = isYou ? Colors.blue[100] : (isSystem ? Colors.grey[100] : Colors.grey[200]);
                return Align(
                  alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    child: SelectableText(
                      msg['text']!,
                      style: TextStyle(fontSize: 13, fontFamily: isSystem ? null : 'monospace'),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
