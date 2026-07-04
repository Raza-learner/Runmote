import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/features/chat/view/widgets/tool_call_card.dart';

void main() {
  testWidgets('ToolCallCard shows tool name', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolCallCard(
          name: 'read_file',
          isStreaming: true,
          isCompleted: false,
        ),
      ),
    ));

    expect(find.text('read_file'), findsOneWidget);
  });

  testWidgets('ToolCallCard shows output when expanded', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolCallCard(
          name: 'bash',
          output: 'Hello World',
          isStreaming: false,
          isCompleted: true,
        ),
      ),
    ));

    // Tap to expand
    await tester.tap(find.text('bash'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('ToolCallCard shows completed icon', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolCallCard(
          name: 'read_file',
          isStreaming: false,
          isCompleted: true,
        ),
      ),
    ));

    // Completed icon should be visible (check_circle)
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
