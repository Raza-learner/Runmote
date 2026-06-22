import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acp_remote/app.dart';

void main() {
  testWidgets('App renders server list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AcpRemoteApp(),
      ),
    );
    expect(find.text('ACP Remote'), findsOneWidget);
    expect(find.text('No agents configured'), findsOneWidget);
  });
}
