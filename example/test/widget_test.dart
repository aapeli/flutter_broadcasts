import 'package:flutter/services.dart';
import 'package:flutter_broadcasts_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const MethodChannel channel = MethodChannel('de.kevlatus.flutter_broadcasts');

  testWidgets('sends the demo broadcast when the button is tapped', (
    WidgetTester tester,
  ) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(calls.map((c) => c.method), contains('startReceiver'));

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    final sent = calls.where((c) => c.method == 'sendBroadcast').single;
    expect(sent.arguments['name'], demoAction);
  });
}
