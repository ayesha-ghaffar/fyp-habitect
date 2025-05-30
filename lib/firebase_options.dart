// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDK0kugffZ0j7escmFEhhX8eSgyx2O_sos',
    appId: '1:217473365424:web:ab75bab125d0c47952d275',
    messagingSenderId: '217473365424',
    projectId: 'fyp1-bab1b',
    authDomain: 'fyp1-bab1b.firebaseapp.com',
    storageBucket: 'fyp1-bab1b.firebasestorage.app',
    measurementId: 'G-7ZHZ7VN8ES',
    databaseURL: 'https://fyp1-bab1b-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWR2iiiZvoc6zXa2ztLFEuzb0FHPM5T-A',
    appId: '1:217473365424:android:9e01b81c0835a8c652d275',
    messagingSenderId: '217473365424',
    projectId: 'fyp1-bab1b',
    storageBucket: 'fyp1-bab1b.firebasestorage.app',
    databaseURL: 'https://fyp1-bab1b-default-rtdb.firebaseio.com/',
  );
}
