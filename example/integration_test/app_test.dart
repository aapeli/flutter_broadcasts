// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_broadcasts_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('receives the broadcast it sends', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    app.main();

    await tester.pumpAndSettle();
    final received = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text && (widget.data?.startsWith('de.kevlatus') ?? false),
    );

    await tester.tap(find.byType(TextButton));
    // The broadcast comes back through the platform asynchronously, so there
    // is no frame scheduled to settle on: poll for it instead.
    for (var i = 0; i < 50 && received.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(received, findsOneWidget);
  });
}
