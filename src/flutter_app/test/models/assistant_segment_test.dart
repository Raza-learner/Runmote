import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/core/models/assistant_segment.dart';

void main() {
  group('AssistantSegment', () {
    test('fromJson parses thought segment', () {
      final json = {
        'id': 'seg-1',
        'kind': 'thought',
        'text': 'reasoning step',
      };
      final seg = AssistantSegment.fromJson(json);
      expect(seg.id, 'seg-1');
      expect(seg.kind, SegmentKind.thought);
      expect(seg.text, 'reasoning step');
      expect(seg.metadata, isEmpty);
    });

    test('fromJson parses toolCall segment with metadata', () {
      final json = {
        'id': 'seg-2',
        'kind': 'toolCall',
        'text': 'bash',
        'metadata': {
          'status': 'running',
          'toolCallId': 'call-1',
        },
      };
      final seg = AssistantSegment.fromJson(json);
      expect(seg.kind, SegmentKind.toolCall);
      expect(seg.text, 'bash');
      expect(seg.metadata['status'], 'running');
      expect(seg.metadata['toolCallId'], 'call-1');
    });

    test('fromJson defaults metadata to empty', () {
      final json = {
        'id': 'seg-3',
        'kind': 'plan',
        'text': 'steps',
      };
      final seg = AssistantSegment.fromJson(json);
      expect(seg.metadata, isEmpty);
    });

    test('copyWith updates text', () {
      final seg = AssistantSegment(
        id: 'seg-1',
        kind: SegmentKind.thought,
        text: 'old',
      );
      final updated = seg.copyWith(text: 'new');
      expect(updated.text, 'new');
      expect(updated.id, 'seg-1');
    });

    test('toJson/fromJson roundtrip for thought segment', () {
      final seg = AssistantSegment(
        id: 'rt-seg-1',
        kind: SegmentKind.thought,
        text: 'reasoning step',
      );
      final json = seg.toJson();
      final restored = AssistantSegment.fromJson(json);
      expect(restored.id, seg.id);
      expect(restored.kind, seg.kind);
      expect(restored.text, seg.text);
      expect(restored.metadata, isEmpty);
    });

    test('toJson/fromJson roundtrip for toolCall segment with metadata', () {
      final seg = AssistantSegment(
        id: 'rt-seg-2',
        kind: SegmentKind.toolCall,
        text: 'bash',
        metadata: {'status': 'completed', 'toolCallId': 'call-1'},
      );
      final json = seg.toJson();
      final restored = AssistantSegment.fromJson(json);
      expect(restored.id, seg.id);
      expect(restored.kind, seg.kind);
      expect(restored.text, seg.text);
      expect(restored.metadata['status'], 'completed');
      expect(restored.metadata['toolCallId'], 'call-1');
    });

    test('toJson/fromJson roundtrip for plan segment', () {
      final seg = AssistantSegment(
        id: 'rt-seg-3',
        kind: SegmentKind.plan,
        text: 'Step 1\nStep 2',
      );
      final json = seg.toJson();
      final restored = AssistantSegment.fromJson(json);
      expect(restored.kind, SegmentKind.plan);
      expect(restored.text, 'Step 1\nStep 2');
    });

    test('equality works', () {
      final a = AssistantSegment(
        id: 'seg-eq-1',
        kind: SegmentKind.thought,
        text: 'test',
      );
      final b = AssistantSegment(
        id: 'seg-eq-1',
        kind: SegmentKind.thought,
        text: 'test',
      );
      expect(a, equals(b));
    });

    test('hashCode consistency', () {
      final a = AssistantSegment(
        id: 'seg-hc-1',
        kind: SegmentKind.toolCall,
        text: 'bash',
      );
      final b = AssistantSegment(
        id: 'seg-hc-1',
        kind: SegmentKind.toolCall,
        text: 'bash',
      );
      expect(a.hashCode, b.hashCode);
    });
  });
}
