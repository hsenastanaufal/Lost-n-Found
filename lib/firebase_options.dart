// File ini di-generate berdasarkan Firebase Project:
// Project ID  : lost-and-found-telu-79dd7
// Project No  : 670685364579
//
// ⚠️  GANTI nilai 'YOUR_...' dengan nilai dari:
//    Firebase Console → Project Settings → Your apps → google-services.json
//
// Cara cepat: jalankan `flutterfire configure` di terminal untuk auto-generate file ini.

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCj3OtkRACIp4HwQbwIsdAphvqLcefX0MQ',
    appId: '1:670685364579:android:95e915d0d7492dcd1e9356',
    messagingSenderId: '670685364579',
    projectId: 'lost-and-found-telu-79dd7',
    storageBucket: 'lost-and-found-telu-79dd7.firebasestorage.app',
  );

  // ── iOS (opsional, isi jika deploy ke iOS) ────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '670685364579',
    projectId: 'lost-and-found-telu-79dd7',
    storageBucket: 'lost-and-found-telu-79dd7.firebasestorage.app',
    iosBundleId: 'com.example.lostnfound',
  );

  // ── Web ──────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBeZ7rHY3IWhc-9fCSNtRTbACHm_6xegsU',
    appId: '1:670685364579:web:69a325cd72adf2ef1e9356',
    messagingSenderId: '670685364579',
    projectId: 'lost-and-found-telu-79dd7',
    storageBucket: 'lost-and-found-telu-79dd7.firebasestorage.app',
    authDomain: 'lost-and-found-telu-79dd7.firebaseapp.com',
    measurementId: 'G-P12BEGVQBP',
  );
}
