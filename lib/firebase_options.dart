// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
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
        return ios;
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
    apiKey: 'AIzaSyB3lQMAt1R7gjQzl_BaYq72HpXEY_fon7M',
    appId: '1:60208463116:web:5dc4b432678fc4a7489d29',
    messagingSenderId: '60208463116',
    projectId: 'ky-app-27178',
    authDomain: 'ky-app-27178.firebaseapp.com',
    storageBucket: 'ky-app-27178.firebasestorage.app',
    measurementId: 'G-R55PG5PHQC',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjAcqG7jZ28A88s4zXzy8ZzLLzTKlI5AU',
    appId: '1:60208463116:ios:e4b78e2fa932b1fb489d29',
    messagingSenderId: '60208463116',
    projectId: 'ky-app-27178',
    storageBucket: 'ky-app-27178.firebasestorage.app',
    iosBundleId: 'com.dokkan.KyTradeMarksDelivery',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArDD-k5hQxOX7NSf9TqLwtDhQwjDLKAFM',
    appId: '1:60208463116:android:86e86c015f3ce015489d29',
    messagingSenderId: '60208463116',
    projectId: 'ky-app-27178',
    storageBucket: 'ky-app-27178.firebasestorage.app',
  );
}
