import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('de.kevlatus.flutter_broadcasts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      calls.add(methodCall);
      switch (methodCall.method) {
        case "startReceiver":
        case "stopReceiver":
        case "sendBroadcast":
          return null;
      }
      throw MissingPluginException();
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  /// Delivers a broadcast from the (mocked) platform side.
  Future<void> receiveFromPlatform(Map<String, dynamic> message) async {
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec()
          .encodeMethodCall(MethodCall('receiveBroadcast', message)),
      (ByteData? data) {},
    );
  }

  group("BroadcastMessage", () {
    test('toMap returns a map containing a message\'s fields.', () async {
      BroadcastMessage message = BroadcastMessage(name: "message.name.1");
      var map = message.toMap();

      expect(map['name'], equals("message.name.1"));
      expect(map['data'], isNull);
      expect(map['timestamp'], isNotNull);

      final data = <String, dynamic>{
        "a": 1,
        "b": "t",
        "d": <int>[300, 200, 0]
      };
      message = BroadcastMessage(name: "message.name.2", data: data);
      map = message.toMap();

      expect(map['name'], equals("message.name.2"));
      expect(mapEquals(map['data'], data), isTrue);
      expect(map['timestamp'], isNotNull);
    });

    test("sendBroadcast passes the message to the platform and completes",
        () async {
      await sendBroadcast(
        BroadcastMessage(name: "message.name", data: {"a": 1}),
      );

      expect(calls, hasLength(1));
      expect(calls.single.method, "sendBroadcast");
      expect(calls.single.arguments['name'], "message.name");
      expect(calls.single.arguments['data'], {"a": 1});
    });
  });

  group("BroadcastReceiver", () {
    test("is not listening before start", () async {
      final receiver = BroadcastReceiver(actions: <String>["broadcast.name"]);
      expect(receiver.isListening, isFalse);
      expect(calls, isEmpty);
    });

    test("toMap carries actions, categories and the export flag", () {
      final receiver = BroadcastReceiver(
        actions: <String>["a.one", "a.two"],
        categories: <String>["c.one"],
        listenToBroadcastsFromOtherApps: false,
      );
      final map = receiver.toMap();

      expect(map['id'], isA<int>());
      expect(map['actions'], <String>["a.one", "a.two"]);
      expect(map['categories'], <String>["c.one"]);
      expect(map['listenToBroadcastsFromOtherApps'], isFalse);
    });

    test("categories default to none, other apps' broadcasts to allowed", () {
      final map = BroadcastReceiver(actions: <String>["a"]).toMap();

      expect(map['categories'], isEmpty);
      expect(map['listenToBroadcastsFromOtherApps'], isTrue);
    });

    test("start registers the receiver on the platform", () async {
      final receiver = BroadcastReceiver(
        actions: <String>["broadcast.name"],
        categories: <String>["broadcast.category"],
      );
      await receiver.start();
      addTearDown(receiver.stop);
      // The registration call goes out asynchronously after start().
      await pumpEventQueue();

      expect(receiver.isListening, isTrue);
      expect(calls.single.method, "startReceiver");
      expect(calls.single.arguments['actions'], <String>["broadcast.name"]);
      expect(
        calls.single.arguments['categories'],
        <String>["broadcast.category"],
      );
    });

    test("start twice throws", () async {
      final receiver = BroadcastReceiver(actions: <String>["broadcast.name"]);
      await receiver.start();
      addTearDown(receiver.stop);

      expect(receiver.start(), throwsStateError);
    });

    test("delivers only the broadcasts addressed to this receiver", () async {
      final receiver = BroadcastReceiver(actions: <String>["broadcast.name"]);
      final other = BroadcastReceiver(actions: <String>["broadcast.other"]);
      final received = <BroadcastMessage>[];
      final receivedByOther = <BroadcastMessage>[];
      receiver.messages.listen(received.add);
      other.messages.listen(receivedByOther.add);
      await receiver.start();
      await other.start();
      addTearDown(receiver.stop);
      addTearDown(other.stop);
      await pumpEventQueue();

      await receiveFromPlatform(<String, dynamic>{
        'receiverId': receiver.toMap()['id'],
        'name': "broadcast.name",
        'data': <String, dynamic>{"code": "6410000000000"},
      });
      await pumpEventQueue();

      expect(received, hasLength(1));
      expect(received.single.name, "broadcast.name");
      expect(received.single.data, {"code": "6410000000000"});
      expect(receivedByOther, isEmpty);
    });

    test("stop unregisters and stops delivery", () async {
      final receiver = BroadcastReceiver(actions: <String>["broadcast.name"]);
      final received = <BroadcastMessage>[];
      receiver.messages.listen(received.add);
      await receiver.start();
      await pumpEventQueue();

      await receiver.stop();

      expect(receiver.isListening, isFalse);
      expect(calls.last.method, "stopReceiver");
      expect(calls.last.arguments['id'], receiver.toMap()['id']);

      await receiveFromPlatform(<String, dynamic>{
        'receiverId': receiver.toMap()['id'],
        'name': "broadcast.name",
        'data': <String, dynamic>{},
      });
      await pumpEventQueue();
      expect(received, isEmpty);
    });

    test("stop without start does nothing", () async {
      final receiver = BroadcastReceiver(actions: <String>["broadcast.name"]);
      await receiver.stop();
      expect(calls, isEmpty);
    });
  });
}
