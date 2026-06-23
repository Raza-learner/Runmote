import 'package:flutter_test/flutter_test.dart';

import 'package:acp_remote/app.dart';

void main() {
  testWidgets('App renders pair screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('ACP Remote'), findsOneWidget);
  });
}
