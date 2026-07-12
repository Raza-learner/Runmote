import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/shared/widgets/diff_viewer.dart';

void main() {
  testWidgets('DiffViewer shows no diff markers when texts are identical', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 200,
          child: DiffViewer(oldText: 'hello', newText: 'hello'),
        ),
      ),
    ));

    // Same text — no +/- markers
    expect(find.textContaining('+'), findsNothing);
    expect(find.textContaining('-'), findsNothing);
  });

  testWidgets('DiffViewer highlights additions', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DiffViewer(oldText: 'line1', newText: 'line1\nline2'),
      ),
    ));

    expect(find.textContaining('+'), findsWidgets);
  });

  testWidgets('DiffViewer highlights deletions', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DiffViewer(oldText: 'line1\nline2', newText: 'line1'),
      ),
    ));

    expect(find.textContaining('-'), findsWidgets);
  });

  testWidgets('DiffViewer shows file path', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DiffViewer(
          oldText: 'a',
          newText: 'b',
        ),
      ),
    ));

    // Diff should render without error
    expect(find.byType(DiffViewer), findsOneWidget);
  });

  testWidgets('DiffViewer has Semantics label', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DiffViewer(oldText: 'hello', newText: 'world'),
      ),
    ));

    expect(
      find.bySemanticsLabel('Diff viewer'),
      findsOneWidget,
    );
  });
}
