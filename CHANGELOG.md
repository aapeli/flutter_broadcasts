## 0.5.0

* Android: builds with Gradle 9 / AGP 9 / Kotlin 2.4 (Flutter 3.50). The removed
  `jcenter()` repository, the `buildscript` block and `kotlinOptions` are gone;
  the plugin now uses the app's `flutter.compileSdkVersion` and
  `flutter.minSdkVersion` and targets Java 17.
* Android: `sendBroadcast` now completes its future (it never answered the
  method call before).
* Android: starting a receiver id that is already registered replaces the old
  registration; stopping an unregistered receiver no longer throws.
* **Breaking** (since 0.4.0): `BroadcastReceiver(names:)` is `actions:`.
  `categories` is new and optional, as is `listenToBroadcastsFromOtherApps`
  (Android 13+).
* Requires Dart 3.5 / Flutter 3.27.

## 0.4.0

* Fix duplicated listeners by removing .asBroadcastStream

## 0.3.0

* Fix Android crash by normalizing broadcast intent data

## 0.1.0

Android integration complete:
* send broadcasts on Android via Context.sendBroadcast

## 0.0.1

Initial Release:
* receive broadcasts on Android using BroadcastReceivers
