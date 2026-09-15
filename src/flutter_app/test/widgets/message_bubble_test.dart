import 'package:acp_remote/core/models/assistant_segment.dart';
import 'package:acp_remote/core/models/chat_message.dart';
import 'package:acp_remote/features/chat/view/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

ChatMessage _assistant({
  required String content,
  required List<AssistantSegment> segments,
  bool isStreaming = true,
}) =>
    ChatMessage(
      id: 'm1',
      role: ChatMessageRole.assistant,
      content: content,
      segments: segments,
      isStreaming: isStreaming,
      createdAt: 0,
    );

AssistantSegment _thought(String id, String text) =>
    AssistantSegment(id: id, kind: SegmentKind.thought, text: text);

AssistantSegment _message(String id, String text) =>
    AssistantSegment(id: id, kind: SegmentKind.message, text: text);

AssistantSegment _tool(String id, String name) =>
    AssistantSegment(id: id, kind: SegmentKind.toolCall, text: name);

CrossFadeState _stateOf(WidgetTester tester) {
  return tester
      .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).first)
      .crossFadeState;
}

void main() {
  testWidgets('thinking stays collapsed when text starts streaming',
      (tester) async {
    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(content: '', segments: [_thought('t1', 'step')]),
      ),
    ));

    await tester.tap(find.text('Thinking Process'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_stateOf(tester), CrossFadeState.showFirst);

    // First text chunk arrives: content goes from empty to non-empty.
    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(content: 'Hello', segments: [_thought('t1', 'step')]),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_stateOf(tester), CrossFadeState.showFirst);
  });

  testWidgets('thinking stays collapsed when a tool call arrives', (tester) async {
    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(content: 'Hi', segments: [_thought('t1', 'step')]),
      ),
    ));

    await tester.tap(find.text('Thinking Process'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_stateOf(tester), CrossFadeState.showFirst);

    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(content: 'Hi', segments: [
          _thought('t1', 'step'),
          const AssistantSegment(
            id: 'tool1',
            kind: SegmentKind.toolCall,
            text: 'read_file',
          ),
        ]),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_stateOf(tester), CrossFadeState.showFirst);
  });

  testWidgets('tool call renders inline between text blocks', (tester) async {
    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(content: 'FirstSecond', segments: [
          _message('m1', 'First'),
          _tool('tool1', 'read_file'),
          _message('m2', 'Second'),
        ], isStreaming: false),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final first = tester.getTopLeft(find.textContaining('First')).dy;
    final tool = tester.getTopLeft(find.text('Executing Tools')).dy;
    final second = tester.getTopLeft(find.textContaining('Second')).dy;

    expect(first, lessThan(tool));
    expect(tool, lessThan(second));
  });

  testWidgets('legacy message without message segments falls back to content first',
      (tester) async {
    await tester.pumpWidget(_wrap(
      MessageBubble(
        message: _assistant(
          content: 'Legacy reply body',
          segments: [_tool('tool1', 'read_file')],
          isStreaming: false,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final body = tester.getTopLeft(find.textContaining('Legacy reply body')).dy;
    final tool = tester.getTopLeft(find.text('Executing Tools')).dy;
    expect(body, lessThan(tool));
  });

  testWidgets('collapsed thinking survives widget re-creation',
      (tester) async {
    Widget build(int gen) => _wrap(KeyedSubtree(
          key: ValueKey(gen),
          child: MessageBubble(
            message: _assistant(
              content: 'Hi',
              segments: [_thought('t1', 'long reasoning')],
            ),
          ),
        ));

    await tester.pumpWidget(build(0));
    await tester.tap(find.text('Thinking Process'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_stateOf(tester), CrossFadeState.showFirst);

    // Force the whole subtree (including ThinkingSection) to be recreated, as
    // happens when the streaming list rebuilds.
    await tester.pumpWidget(build(1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_stateOf(tester), CrossFadeState.showFirst);
  });
}
