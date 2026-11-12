// Firebase client options from the registered TeamUp apps in prm-lab3-cc39e.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError(
      'Firebase is configured for TeamUp on Android and web.',
    );
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDsSyRcZVDv5eTO0BUd6_YGct8KA17VegY',
    appId: '1:508852657563:android:cf19f917496710336a553e',
    messagingSenderId: '508852657563',
    projectId: 'prm-lab3-cc39e',
    storageBucket: 'prm-lab3-cc39e.firebasestorage.app',
  );

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDDn6w_pUyOfXGP9pYJ_RFdbZkDyZUouOw',
    appId: '1:508852657563:web:0f3bdc1879cfffc36a553e',
    messagingSenderId: '508852657563',
    projectId: 'prm-lab3-cc39e',
    authDomain: 'prm-lab3-cc39e.firebaseapp.com',
    storageBucket: 'prm-lab3-cc39e.firebasestorage.app',
    measurementId: 'G-L525EDMJJC',
  );
}
