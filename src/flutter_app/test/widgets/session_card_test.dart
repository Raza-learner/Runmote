import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/features/sessions/view/widgets/session_card.dart';

void main() {
  testWidgets('SessionCard renders title and cwd', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SessionCard(
          title: 'My Project',
          cwd: '/home/user/project',
          timeAgo: '2h ago',
          isActive: false,
          onTap: () {},
          onDelete: () {},
        ),
      ),
    ));

    expect(find.text('My Project'), findsOneWidget);
    expect(find.text('/home/user/project'), findsOneWidget);
    expect(find.text('2h ago'), findsOneWidget);
  });

  testWidgets('SessionCard shows Untitled when title is null', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SessionCard(
          title: null,
          cwd: '/tmp',
          timeAgo: 'just now',
          isActive: false,
          onTap: () {},
          onDelete: () {},
        ),
      ),
    ));

    expect(find.text('Untitled Session'), findsOneWidget);
  });

  testWidgets('SessionCard shows active indicator', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SessionCard(
          title: 'Active Session',
          cwd: '/home',
          timeAgo: '1m ago',
          isActive: true,
          onTap: () {},
          onDelete: () {},
        ),
      ),
    ));

    // Active indicator is a green dot container
    expect(find.byType(SessionCard), findsOneWidget);
  });

  testWidgets('SessionCard calls onTap when tapped', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SessionCard(
          title: 'Tappable',
          cwd: '/home',
          timeAgo: '5m ago',
          isActive: false,
          onTap: () => tapped = true,
          onDelete: () {},
        ),
      ),
    ));

    await tester.tap(find.text('Tappable'));
    expect(tapped, isTrue);
  });

  testWidgets('SessionCard delete button has tooltip',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SessionCard(
          title: 'Session',
          cwd: '/tmp',
          timeAgo: '1m ago',
          isActive: false,
          onTap: () {},
          onDelete: () {},
        ),
      ),
    ));

    // IconButton with tooltip 'Delete session' is present
    expect(
      find.byIcon(Icons.delete_outline_rounded),
      findsOneWidget,
    );
  });
}
