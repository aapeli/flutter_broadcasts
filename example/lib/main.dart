import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:material_ui/material_ui.dart';

const String demoAction = "de.kevlatus.flutter_broadcasts_example.demo_action";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // The demo only sends the broadcast to itself, so the receiver does not
  // need to be exported to other apps.
  final BroadcastReceiver receiver = BroadcastReceiver(
    actions: <String>[demoAction],
    listenToBroadcastsFromOtherApps: false,
  );

  @override
  void initState() {
    super.initState();
    receiver.start();
  }

  @override
  void dispose() {
    receiver.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Broadcasts Demo')),
        body: Column(
          children: [
            TextButton(
              child: const Text('Send Broadcast'),
              onPressed: () {
                sendBroadcast(BroadcastMessage(name: demoAction));
              },
            ),
            StreamBuilder<BroadcastMessage>(
              stream: receiver.messages,
              builder: (context, snapshot) {
                return Text(snapshot.data?.name ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}
