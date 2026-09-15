import 'package:acp_remote/features/chat/view/widgets/thinking_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

CrossFadeState _stateOf(WidgetTester tester) {
  return tester
      .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
      .crossFadeState;
}

void main() {
  testWidgets('tap collapses thinking while streaming', (tester) async {
    await tester.pumpWidget(_wrap(
      const ThinkingSection(text: 'reasoning step one', isStreaming: true),
    ));
    expect(_stateOf(tester), CrossFadeState.showSecond);

    await tester.tap(find.text('Thinking Process'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_stateOf(tester), CrossFadeState.showFirst);
  });

  testWidgets('stays collapsed as new streaming chunks arrive', (tester) async {
    await tester.pumpWidget(_wrap(
      const ThinkingSection(text: 'step one', isStreaming: true),
    ));

    await tester.tap(find.text('Thinking Process'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_stateOf(tester), CrossFadeState.showFirst);

    await tester.pumpWidget(_wrap(
      const ThinkingSection(text: 'step one step two', isStreaming: true),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_stateOf(tester), CrossFadeState.showFirst);
  });
}
