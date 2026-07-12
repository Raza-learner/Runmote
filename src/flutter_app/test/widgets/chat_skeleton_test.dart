import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/features/chat/view/widgets/chat_skeleton.dart';

void main() {
  testWidgets('ChatSkeleton renders placeholder bubbles',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ChatSkeleton()),
    ));

    // The skeleton renders 6 placeholder containers
    expect(find.byType(Container), findsNWidgets(6));
  });

  testWidgets('ChatSkeleton animation runs', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ChatSkeleton()),
    ));

    final before = tester.binding.toString();

    // Let animation advance
    await tester.pump(const Duration(milliseconds: 600));

    // Widget still renders after animation tick
    expect(find.byType(Container), findsNWidgets(6));
  });

  testWidgets('ChatSkeleton has Semantics label', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ChatSkeleton()),
    ));

    expect(
      find.bySemanticsLabel('Chat loading skeleton'),
      findsOneWidget,
    );
  });
}
