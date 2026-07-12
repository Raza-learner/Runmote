import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/core/models/mcp_server.dart';

void main() {
  group('McpServer', () {
    test('toJson/fromJson roundtrip for stdio server', () {
      final server = McpServer(
        name: 'test-server',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-filesystem', '/tmp'],
        env: [
          {'name': 'KEY', 'value': 'val'},
        ],
      );
      final json = server.toJson();
      final restored = McpServer.fromJson(json);
      expect(restored.name, 'test-server');
      expect(restored.command, 'npx');
      expect(restored.args, ['-y', '@modelcontextprotocol/server-filesystem', '/tmp']);
      expect(restored.env, [
        {'name': 'KEY', 'value': 'val'},
      ]);
      expect(restored.type, 'stdio');
      expect(restored.url, isNull);
    });

    test('toJson/fromJson roundtrip for http server', () {
      final server = McpServer(
        name: 'remote-mcp',
        command: '',
        type: 'http',
        url: 'https://example.com/mcp',
        headers: [
          {'name': 'Authorization', 'value': 'Bearer token'},
        ],
      );
      final json = server.toJson();
      final restored = McpServer.fromJson(json);
      expect(restored.name, 'remote-mcp');
      expect(restored.type, 'http');
      expect(restored.url, 'https://example.com/mcp');
      expect(restored.headers, [
        {'name': 'Authorization', 'value': 'Bearer token'},
      ]);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'name': 'minimal',
        'command': 'echo',
      };
      final server = McpServer.fromJson(json);
      expect(server.name, 'minimal');
      expect(server.command, 'echo');
      expect(server.args, isEmpty);
      expect(server.env, isEmpty);
      expect(server.type, 'stdio');
      expect(server.url, isNull);
      expect(server.headers, isNull);
    });

    test('fromJson handles null env and args', () {
      final json = {
        'name': 'nulls',
        'command': 'cmd',
        'args': null,
        'env': null,
      };
      final server = McpServer.fromJson(json);
      expect(server.args, isEmpty);
      expect(server.env, isEmpty);
    });

    test('toJson omits null url and headers for stdio', () {
      final server = McpServer(name: 'stdio-only', command: 'echo');
      final json = server.toJson();
      expect(json.containsKey('url'), isFalse);
      expect(json.containsKey('headers'), isFalse);
    });

    test('identical servers have same field values', () {
      final a = McpServer(name: 'srv', command: 'npx', args: ['run']);
      final b = McpServer(name: 'srv', command: 'npx', args: ['run']);
      expect(a.name, b.name);
      expect(a.command, b.command);
      expect(a.args, b.args);
      expect(a.type, b.type);
    });
  });
}
