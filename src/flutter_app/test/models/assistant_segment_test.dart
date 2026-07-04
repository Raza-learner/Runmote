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
  });
}
