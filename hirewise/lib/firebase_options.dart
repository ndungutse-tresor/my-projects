// ============================================================
// PLACEHOLDER — replace this file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// FlutterFire CLI will overwrite this file with your real
// Firebase project credentials for every target platform.
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Replace ALL values below after running `flutterfire configure` ──

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlsVD9YHvjJJipDJqnGnpZc99oGGVo4C4',
    appId: '1:267639733069:web:8f1396e73c2ae109ead504',
    messagingSenderId: '267639733069',
    projectId: 'hirewise-dc01a',
    authDomain: 'hirewise-dc01a.firebaseapp.com',
    storageBucket: 'hirewise-dc01a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCECsUIfEHTIQ3mNMoCeKK4Vw4yGg1gCPk',
    appId: '1:267639733069:android:4a1773326f49ffe9ead504',
    messagingSenderId: '267639733069',
    projectId: 'hirewise-dc01a',
    storageBucket: 'hirewise-dc01a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBp9PkgTL4at9GmQ839qUBRZZRIxDypfPI',
    appId: '1:267639733069:ios:bcc87ee157d2b21fead504',
    messagingSenderId: '267639733069',
    projectId: 'hirewise-dc01a',
    storageBucket: 'hirewise-dc01a.firebasestorage.app',
    iosClientId: '267639733069-vggjlhbrorfulnl9ujlaut28sf9r9546.apps.googleusercontent.com',
    iosBundleId: 'com.example.hirewise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlsVD9YHvjJJipDJqnGnpZc99oGGVo4C4',
    appId: '1:267639733069:web:85b188468c5becd2ead504',
    messagingSenderId: '267639733069',
    projectId: 'hirewise-dc01a',
    authDomain: 'hirewise-dc01a.firebaseapp.com',
    storageBucket: 'hirewise-dc01a.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_VALUE',
    appId: 'REPLACE_WITH_REAL_VALUE',
    messagingSenderId: 'REPLACE_WITH_REAL_VALUE',
    projectId: 'REPLACE_WITH_REAL_VALUE',
    storageBucket: 'REPLACE_WITH_REAL_VALUE',
    iosClientId: 'REPLACE_WITH_REAL_VALUE',
    iosBundleId: 'com.hirewise.app',
  );
}