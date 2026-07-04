import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acp_remote/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ProviderScope(child: const App()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
