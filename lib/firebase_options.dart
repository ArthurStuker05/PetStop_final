import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions não está configurado para esta plataforma (Android/iOS usam arquivos nativos).',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCO6GOFXXOzLSLDgUxxck9NBZ3s5yEHSXA',
    appId: '1:932088126382:web:1589c2bc444f4e60d4c63f',
    messagingSenderId: '932088126382',
    projectId: 'apppetstop-bd14f',
    authDomain: 'apppetstop-bd14f.firebaseapp.com',
    storageBucket: 'apppetstop-bd14f.firebasestorage.app',
    measurementId: 'G-ZZH4YHP46H',
  );
}