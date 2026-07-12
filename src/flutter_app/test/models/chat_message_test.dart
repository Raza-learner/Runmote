import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/core/models/chat_message.dart';
import 'package:acp_remote/core/models/assistant_segment.dart';

void main() {
  group('ChatMessage', () {
    test('fromJson parses user message', () {
      final json = {
        'id': 'msg-1',
        'role': 'user',
        'content': 'Hello',
        'segments': <Map<String, dynamic>>[],
        'isStreaming': false,
        'createdAt': 1000000,
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.id, 'msg-1');
      expect(msg.role, ChatMessageRole.user);
      expect(msg.content, 'Hello');
      expect(msg.segments, isEmpty);
      expect(msg.isStreaming, false);
      expect(msg.createdAt, 1000000);
    });

    test('fromJson parses assistant message without segments', () {
      final json = {
        'id': 'msg-2',
        'role': 'assistant',
        'content': 'Hi there',
        'createdAt': 2000000,
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.role, ChatMessageRole.assistant);
      expect(msg.content, 'Hi there');
      expect(msg.segments, isEmpty);
    });

    test('fromJson parses assistant message with segments', () {
      final json = {
        'id': 'msg-3',
        'role': 'assistant',
        'content': '',
        'createdAt': 3000000,
        'segments': [
          {
            'id': 'seg-1',
            'kind': 'thought',
            'text': 'thinking...',
          },
          {
            'id': 'seg-2',
            'kind': 'toolCall',
            'text': 'read_file',
            'metadata': {'status': 'running'},
          },
        ],
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.segments.length, 2);
      expect(msg.segments[0].kind, SegmentKind.thought);
      expect(msg.segments[0].text, 'thinking...');
      expect(msg.segments[1].kind, SegmentKind.toolCall);
      expect(msg.segments[1].metadata['status'], 'running');
    });

    test('copyWith preserves other fields', () {
      final msg = ChatMessage(
        id: 'msg-1',
        role: ChatMessageRole.assistant,
        content: 'original',
        createdAt: 1000,
      );
      final updated = msg.copyWith(content: 'modified');
      expect(updated.id, 'msg-1');
      expect(updated.role, ChatMessageRole.assistant);
      expect(updated.content, 'modified');
      expect(updated.createdAt, 1000);
    });

    test('equality works', () {
      final a = ChatMessage(
        id: 'm1',
        role: ChatMessageRole.user,
        content: 'test',
        createdAt: 100,
      );
      final b = ChatMessage(
        id: 'm1',
        role: ChatMessageRole.user,
        content: 'test',
        createdAt: 100,
      );
      expect(a, equals(b));
    });

    test('inequality detects different id', () {
      final a = ChatMessage(
        id: 'm1',
        role: ChatMessageRole.user,
        content: 'test',
        createdAt: 100,
      );
      final b = ChatMessage(
        id: 'm2',
        role: ChatMessageRole.user,
        content: 'test',
        createdAt: 100,
      );
      expect(a, isNot(equals(b)));
    });

    test('toJson/fromJson roundtrip for user message', () {
      final msg = ChatMessage(
        id: 'rt-1',
        role: ChatMessageRole.user,
        content: 'Hello',
        createdAt: 5000,
      );
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored.id, msg.id);
      expect(restored.role, msg.role);
      expect(restored.content, msg.content);
      expect(restored.createdAt, msg.createdAt);
      expect(restored.isStreaming, msg.isStreaming);
      expect(restored.segments, isEmpty);
    });

    test('toJson/fromJson roundtrip for assistant message with segments', () {
      final msg = ChatMessage(
        id: 'rt-2',
        role: ChatMessageRole.assistant,
        content: '',
        createdAt: 6000,
        segments: [
          AssistantSegment(
            id: 'seg-rt-1',
            kind: SegmentKind.thought,
            text: 'thinking...',
          ),
          AssistantSegment(
            id: 'seg-rt-2',
            kind: SegmentKind.toolCall,
            text: 'bash',
            metadata: {'status': 'running'},
          ),
        ],
        isStreaming: true,
      );
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored.id, msg.id);
      expect(restored.role, msg.role);
      expect(restored.segments.length, 2);
      expect(restored.segments[0].kind, SegmentKind.thought);
      expect(restored.segments[0].text, 'thinking...');
      expect(restored.segments[1].kind, SegmentKind.toolCall);
      expect(restored.segments[1].metadata['status'], 'running');
      expect(restored.isStreaming, msg.isStreaming);
    });
  });
}
