// File generated manually to bypass flutterfire cli requirement.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAd9xD10vW6rQOO0dT06O8HQCyRKs0eQME',
    appId: '1:388080532524:web:c81eb8fc871c96a1d0a589',
    messagingSenderId: '388080532524',
    projectId: 'futter-kurs',
    authDomain: 'futter-kurs.firebaseapp.com',
    storageBucket: 'futter-kurs.firebasestorage.app',
    measurementId: 'G-M0LNJ68B1Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0GyjQkddnJofrrse4qIJYJaMgdKPTvmY',
    appId: '1:388080532524:android:d75d7a3e867ba8f8d0a589',
    messagingSenderId: '388080532524',
    projectId: 'futter-kurs',
    storageBucket: 'futter-kurs.firebasestorage.app',
  );
}
