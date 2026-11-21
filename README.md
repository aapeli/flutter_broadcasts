[![](https://img.shields.io/pub/v/flutter_broadcasts)](https://pub.dev/packages/flutter_broadcasts)

# Flutter Broadcasts

A plugin for sending and receiving broadcasts with Android intents and iOS notifications. The API is inspired by Android's [BroadcastReceivers](https://developer.android.com/reference/android/content/BroadcastReceiver) and uses the [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter) internally on iOS.

## Quick Start

This fork is not published on pub.dev. Add it as a git dependency:

```yaml
dependencies:
  flutter_broadcasts:
    git:
      url: https://github.com/aapeli/flutter_broadcasts.git
      ref: main
```

Then subscribe to broadcasts like this:

```dart
BroadcastReceiver receiver = BroadcastReceiver(
  actions: <String>["de.kevlatus.broadcast"],
  // Optional: categories the broadcasts must belong to.
  categories: <String>[],
  // Android 13+: set to false to only receive this app's own broadcasts.
  listenToBroadcastsFromOtherApps: true,
);
receiver.messages.listen(print);
receiver.start();
```

Send one with:

```dart
await sendBroadcast(BroadcastMessage(name: "de.kevlatus.broadcast"));
```

## Requirements

Android builds need Flutter 3.27 or newer and a Kotlin Gradle plugin 2.0 or
newer in the app. The plugin builds with Gradle 9 / AGP 9 (Flutter 3.50).

## Roadmap

This package is currently under construction. Below you can find a quick overview of its implementation status. Contributions are welcome, if you are missing features.

- [x] implement broadcast receiver on Android
- [x] implement broadcast sending on Android
- [ ] implement NSNotificationCenter subscriptions on iOS
- [ ] implement NSNotificationCenter notifications on iOS

## Contributions

Contributions are much appreciated, but keep in mind that this package is supposed to be generic and only expose native broadcast APIs like [Android's BroadcastReceivers](https://developer.android.com/reference/android/content/BroadcastReceiver) and the [iOS NotificiationCenter](https://developer.apple.com/documentation/foundation/notificationcenter). Consider creating separate packages for sending and receiving specific broadcast instances.

If you have any ideas for extending this package to other platforms, feel free to
[open a pull request](https://github.com/kevlatus/flutter_broadcasts/pulls) or
[raise an issue](https://github.com/kevlatus/flutter_broadcasts/issues).
